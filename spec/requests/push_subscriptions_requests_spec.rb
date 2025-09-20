require 'rails_helper'

RSpec.describe "Push Subscriptions", type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:plan) { create(:plan, activated_at: Time.current, position: 1) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  before do
    # Stub Stripe customer creation for any email
    stub_request(:post, 'https://api.stripe.com/v1/customers')
      .to_return(status: 200, body: { id: 'cus_test123' }.to_json, headers: { 'Content-Type' => 'application/json' })
    # Stub Stripe subscription creation
    stub_request(:post, 'https://api.stripe.com/v1/subscriptions')
      .to_return(status: 200, body: { id: 'sub_test123' }.to_json, headers: { 'Content-Type' => 'application/json' })
    # Stub Stripe setup intent creation
    stub_request(:post, 'https://api.stripe.com/v1/setup_intents')
      .to_return(status: 200, body: { id: 'seti_test123', client_secret: 'seti_secret' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  let(:user) { create(:user, :confirmed) }
  let(:unsaved_push_subscription) { build(:push_subscription, user: user) }
  let(:json_ps_attributes) do
    unsaved_push_subscription
      .as_json(only: [ :endpoint, :expires_at, :public_key, :auth_secret ])
      .with_indifferent_access
  end

  let(:raw_subscription_params) do
    {
      endpoint: json_ps_attributes[:endpoint],
      keys: {
        auth: json_ps_attributes[:auth_secret],
        p256dh: json_ps_attributes[:public_key]
      }
    }
  end
  let(:valid_params) do
    {
      subscription: raw_subscription_params
    }
  end

  context "when creating a new push subscription" do
    before do
      sign_in user
    end

    subject(:create_push_subscription) do
      post push_subscriptions_path, params: params
    end

    context "with valid params" do
      let(:params) { valid_params }

      it "responds correctly when another subscription with the same attributes doesn't already exist" do
        create_push_subscription
        expect(response).to be_successful
      end

      it "creates the subscription when another subscription with the same attributes doesn't already exist" do
        expect { create_push_subscription }.to change(user.push_subscriptions, :count).by(1)
      end

      it "responds correctly even when another subscription with the same attributes already exists" do
        unsaved_push_subscription.save!
        create_push_subscription
        expect(response).to be_successful
      end

      it "doesn't change the subscription count when another subscription with the same attributes already exists" do
        unsaved_push_subscription.save!
        expect { create_push_subscription }.not_to change(user.push_subscriptions, :count)
      end
    end

    context "with invalid params" do
      context "when missing the subscription param key" do
        let(:params) { raw_subscription_params }

        it "returns a parameter missing error" do
          expect do
            create_push_subscription
          end.not_to change(PushSubscription, :count)

          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when missing the endpoint attribute" do
        let(:params) do
          { subscription: raw_subscription_params.except(:endpoint) }
        end

        it "returns back a 500 error" do
          create_push_subscription
          expect(response).not_to be_successful
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  context "when unsubscribing from a push subscription" do
    before do
      sign_in user
    end

    subject(:unsubscribe_push_subscription) do
      delete unsubscribe_push_subscriptions_path, params: params
    end

    context "with valid params" do
      let(:params) { valid_params }

      it "deletes the subscription when it exists" do
        unsaved_push_subscription.save!
        unsubscribe_push_subscription
        expect(response).to be_successful
      end

      it "fails to delete the subscription if it does not exist yet" do
        unsubscribe_push_subscription
        expect(response).not_to be_successful
      end
    end

    context "with invalid params" do
      context "when missing the subscription param key" do
        let(:params) { raw_subscription_params }

        it "raises a parameter missing error" do
          expect do
            unsubscribe_push_subscription
          end.not_to change(PushSubscription, :count)

          expect(response).to have_http_status(:bad_request)
        end

        it "does not delete a subscription even if it exists after raising an error" do
          expect do
            unsubscribe_push_subscription
          end.not_to change(PushSubscription, :count)

          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when missing the endpoint attribute" do
        let(:params) { valid_params.except(:endpoint) }

        it "returns back a 404 when missing the endpoint attribute" do
          unsubscribe_push_subscription
          expect(response).not_to be_successful
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  context "when unsubscribing from all push subscriptions" do
    before do
      sign_in user
    end

    subject(:unsubscribe_all_push_subscription) do
      delete unsubscribe_all_push_subscriptions_path, params: {}
    end

    let(:generated_subscription_count) { rand(1..10) }

    before do
      create_list(:push_subscription, generated_subscription_count, user: user)
    end

    it "successfully deletes all subscriptions" do
      expect(generated_subscription_count).not_to eq(0)
      expect(user.push_subscriptions.size).to eq(generated_subscription_count)

      unsubscribe_all_push_subscription
      expect(response).to be_successful
      expect(user.push_subscriptions.size).to eq(0)
    end
  end
end

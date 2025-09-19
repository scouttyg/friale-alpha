# frozen_string_literal: true

require 'rails_helper'
require 'support/env_helpers'

RSpec.describe PushSubscriptions::Pusher do
  before do
    free_plan = create(:plan, name: 'Free', position: 1)
    create(:plan_period, plan: free_plan, interval: 'MONTH', stripe_price_id: 'price_mock_123')

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

  let!(:user) { create(:user, :confirmed) }
  let!(:push_subscription) { create(:push_subscription, user: user) }
  let!(:stubbed_domain) do
    uri = Addressable::URI.parse(push_subscription.endpoint)
    uri.domain
  end
  let!(:test_vapid_key) { WebPush.generate_key }

  context "when vapid configuration is set" do
    before do
      temp_env = {
        "WEB_PUSH_PUBLIC_KEY" => test_vapid_key.public_key,
        "WEB_PUSH_PRIVATE_KEY" => test_vapid_key.private_key,
        "WEB_PUSH_EMAIL" => Faker::Internet.unique.email
      }
      set_temporary_env(temp_env)
      reset_and_reload_class(described_class)
    end

    after do
      remove_temporary_env
      reset_and_reload_class(described_class)
    end

    context "when the user is set" do
      let(:pusher) { described_class.new(user: user, title: "My sample title", body: "My sample body") }

      context 'when the service works successfully' do
        before do
          stub_request(:post, /#{stubbed_domain}/).to_return(status: 200, body: "Cool")
        end

        it 'does not raise an error' do
          expect { pusher.push! }.not_to raise_error
        end

        it 'returns back true' do
          expect(pusher.push!).to be(true)
        end
      end

      context 'when the service returns that the subscription has expired' do
        before do
          stub_request(:post, /#{stubbed_domain}/).to_return(status: 410, body: "This push subscription has gone far, far away")
        end

        it 'does not raise an error' do
          expect { pusher.push! }.not_to raise_error
        end

        it 'returns back false and sets the expiration date on the push subscription' do
          expect(pusher.push!).to be(false)
          push_subscription.reload
          expect(push_subscription).to be_expired
        end
      end

      context 'when the service returns that the subscription cannot be found' do
        before do
          stub_request(:post, /#{stubbed_domain}/).to_return(status: 404, body: "This push subscription cannot be found!")
        end

        it 'does not raise an error' do
          expect { pusher.push! }.not_to raise_error
        end

        it 'returns back false and deletes the push subscription' do
          expect do
            expect(pusher.push!).to be(false)
          end.to change(user.push_subscriptions, :size).by(-1)
        end
      end
    end

    context "when the service is initialized with wrong values" do
      before do
        stub_request(:post, /#{stubbed_domain}/).to_return(status: 200, body: "Cool")
      end

      context "when the user is not set" do
        let(:pusher) { described_class.new(user: nil, title: "My sample title", body: "My sample body") }

        it 'does not raise an error' do
          expect { pusher.push! }.not_to raise_error
        end

        it 'returns back false' do
          expect(pusher.push!).to be(false)
        end
      end

      context "when the title is not set" do
        let(:pusher) { described_class.new(user: user, title: nil, body: "My sample body") }

        it 'does not raise an error' do
          expect { pusher.push! }.not_to raise_error
        end

        it 'returns back false' do
          expect(pusher.push!).to be(false)
        end
      end

      context "when the body is not set" do
        let(:pusher) { described_class.new(user: user, title: "My sample title", body: nil) }

        it 'does not raise an error' do
          expect { pusher.push! }.not_to raise_error
        end

        it 'returns back false' do
          expect(pusher.push!).to be(false)
        end
      end

      context "when the push subscription is invalid" do
        let(:pusher) { described_class.new(user: user, title: "My sample title", body: "My sample body") }
        let(:push_subscription) { create(:push_subscription, :invalid, user: user) }

        it 'does not raise an error' do
          expect { pusher.push! }.not_to raise_error
        end

        it 'returns back false' do
          expect(pusher.push!).to be(false)
        end
      end
    end
  end

  context "when vapid configuration is not set" do
    let(:pusher) { described_class.new(user: user, title: "My sample title", body: "My sample body") }

    it 'raises an error' do
      expect { pusher.push! }.to raise_error(described_class::InvalidVapidConfigurationError)
    end
  end
end

require 'rails_helper'

RSpec.describe 'Billings', type: :request do
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

  context 'when checking the billings pages' do
    let!(:user) { create(:user) }

    describe 'GET /plan' do
      it 'returns http success' do
        sign_in user
        account = user.personal_account
        get plan_settings_billings_path(account)
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /overview' do
      it 'returns http success' do
        sign_in user
        account = user.personal_account
        get overview_settings_billings_path(account)
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /payment_methods' do
      it 'returns http success' do
        sign_in user
        account = user.personal_account
        get settings_payment_methods_path(account)
        expect(response).to have_http_status(:success)
      end
    end
  end
end

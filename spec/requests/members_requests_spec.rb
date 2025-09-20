require 'rails_helper'

RSpec.describe 'Members', type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:plan) { create(:plan, activated_at: Time.current, position: 1, member_limit: 10) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  before do
    # Stub Stripe customer creation for any email
    stub_request(:post, 'https://api.stripe.com/v1/customers')
      .to_return(status: 200, body: { id: 'cus_test123' }.to_json, headers: { 'Content-Type' => 'application/json' })
    # Stub Stripe subscription creation
    stub_request(:post, 'https://api.stripe.com/v1/subscriptions')
      .to_return(status: 200, body: { id: 'sub_test123' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  context 'when checking the members pages' do
    let!(:user) { create(:user, :confirmed) }
    let!(:account) { user.personal_account }
    let!(:subscription) { create(:subscription, account: account, plan: plan, plan_period: plan_period) }

    describe 'GET /accounts/:id/settings/members' do
      it 'returns http success for members index' do
        sign_in user
        get "/accounts/#{account.id}/settings/members"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /accounts/:id/settings/members/new' do
      it 'returns http success for new member page' do
        sign_in user
        get "/accounts/#{account.id}/settings/members/new"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /accounts/:id/settings/members/:id/edit' do
      let!(:member) { create(:member, :invited, source: account, creator: user, type: "AccountMember") }

      it 'returns http success for edit member page' do
        sign_in user
        get "/accounts/#{account.id}/settings/members/#{member.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:plan) { create(:plan, activated_at: Time.current, position: 1, member_limit: 10) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  context 'when checking the accounts pages' do
    let!(:user) { create(:user, :confirmed) }
    let!(:account) { user.personal_account }
    let!(:subscription) { create(:subscription, account: account, plan: plan, plan_period: plan_period) }

    describe 'GET /accounts/:id/settings' do
      it 'returns http success for account edit/settings page' do
        sign_in user
        get settings_account_url(account)
        expect(response).to have_http_status(:success)
      end
    end
  end
end

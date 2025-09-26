require 'rails_helper'

RSpec.describe 'Funds', type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:plan) { create(:plan, activated_at: Time.current, position: 1, member_limit: 10) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  context 'when checking the funds pages' do
    let!(:user) { create(:user, :confirmed) }
    let!(:investor_account) { create(:investor_account) }
    let!(:firm_account) { create(:firm_account) }
    let!(:subscription) { create(:subscription, account: investor_account, plan: plan, plan_period: plan_period) }
    let!(:fund) { create(:fund, firm_account: firm_account, name: "Test Fund") }
    let!(:fund_investment) { create(:fund_investor_investment, fund: fund, investor_account: investor_account, capital_commitment_cents: 100000, capital_funded_cents: 50000) }

    before do
      # Make the user a member of the investor account
      create(:account_member, :owner, source: investor_account, user: user, creator: user)
      sign_in user
    end

    def switch_to_account(account)
      post switch_account_path(account)
    end

    describe 'GET /funds' do
      it 'returns http success for funds index page' do
        switch_to_account(investor_account)
        get funds_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Funds")
        expect(response.body).to include(fund.name)
      end

      it 'displays fund information correctly' do
        switch_to_account(investor_account)
        get funds_path
        expect(response.body).to include("Test Fund")
        expect(response.body).to include("$1,000") # capital commitment
      end

      it 'handles empty funds list' do
        fund_investment.destroy
        fund.destroy

        switch_to_account(investor_account)
        get funds_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("No fund investments found")
      end
    end

    describe 'GET /funds/:id' do
      it 'returns http success for funds show page' do
        switch_to_account(investor_account)
        get fund_path(fund)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(fund.name)
      end

      it 'displays fund summary information' do
        switch_to_account(investor_account)
        get fund_path(fund)
        expect(response.body).to include("Fund Summary")
        expect(response.body).to include("Your Summary")
        expect(response.body).to include("Open Positions")
        expect(response.body).to include("Closed Positions")
        expect(response.body).to include("Transactions")
        expect(response.body).to include("Documents")
      end

      it 'displays investor information correctly' do
        switch_to_account(investor_account)
        get fund_path(fund)
        expect(response.body).to include(investor_account.name)
        expect(response.body).to include("$1,000") # capital commitment
        expect(response.body).to include("$500")   # capital funded
      end

      it 'handles fund without investment' do
        fund_investment.destroy

        switch_to_account(investor_account)
        get fund_path(fund)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("No investment data found")
      end

      it 'returns 404 for non-existent fund' do
        switch_to_account(investor_account)
        get fund_path(999999)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to sign in for funds index' do
        get funds_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to sign in for funds show' do
        get fund_path(fund)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with fund positions and transactions' do
      let!(:company) { create(:company, firm_account: firm_account, name: "Test Company") }
      let!(:position) { create(:position, fund: fund, company: company, invested_capital_cents: 50000, returned_capital_cents: 0) }
      let!(:transaction) { create(:fund_investor_transaction, fund_investor_investment: fund_investment, amount_cents: 25000, status: :COMPLETE, date: Date.current) }

      it 'displays positions in show page' do
        switch_to_account(investor_account)
        get fund_path(fund)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Test Company")
        expect(response.body).to include("$500") # invested capital
      end

      it 'displays transactions in show page' do
        switch_to_account(investor_account)
        get fund_path(fund)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("$250") # transaction amount
      end
    end

    context 'with fund documents' do
      let!(:document) { create(:document, fund: fund, name: "Fund Agreement", date: Date.current) }

      it 'displays documents in show page' do
        switch_to_account(investor_account)
        get fund_path(fund)

        unless response.successful?
          puts "Response status: #{response.status}"
          puts "Response body:"
          puts response.body
        end

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Fund Agreement")
        expect(response.body).to include("Download")
      end
    end
  end
end

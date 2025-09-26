require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:plan) { create(:plan, activated_at: Time.current, position: 1, member_limit: 10) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  context 'when checking the companies pages' do
    let!(:user) { create(:user, :confirmed) }
    let!(:investor_account) { create(:investor_account) }
    let!(:firm_account) { create(:firm_account) }
    let!(:subscription) { create(:subscription, account: investor_account, plan: plan, plan_period: plan_period) }
    let!(:fund) { create(:fund, firm_account: firm_account, name: "Test Fund") }
    let!(:fund_investment) { create(:fund_investor_investment, fund: fund, investor_account: investor_account, capital_commitment_cents: 100000, capital_funded_cents: 50000) }
    let!(:company) { create(:company, firm_account: firm_account, name: "Test Company") }
    let!(:position) { create(:position, fund: fund, company: company, invested_capital_cents: 50000, returned_capital_cents: 0, open_date: Date.current) }

    before do
      # Make the user a member of the investor account
      create(:account_member, :owner, source: investor_account, user: user, creator: user)
      sign_in user
    end

    def switch_to_account(account)
      post switch_account_path(account)
    end

    describe 'GET /companies' do
      it 'returns http success for companies index page' do
        switch_to_account(investor_account)
        get companies_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Companies")
        expect(response.body).to include("Portfolio Companies")
      end

      it 'displays company information correctly' do
        switch_to_account(investor_account)
        get companies_path
        expect(response.body).to include("Test Company")
        expect(response.body).to include("Test Fund")
        expect(response.body).to include("$500") # invested capital
      end

      it 'handles empty companies list' do
        position.destroy
        company.destroy

        switch_to_account(investor_account)
        get companies_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("No companies found in your portfolio")
      end

      it 'shows only companies accessible to the investor' do
        # Create another fund and company that the investor doesn't have access to
        other_fund = create(:fund, firm_account: firm_account, name: "Other Fund")
        other_company = create(:company, firm_account: firm_account, name: "Other Company")
        create(:position, fund: other_fund, company: other_company, invested_capital_cents: 25000)

        switch_to_account(investor_account)
        get companies_path
        expect(response.body).to include("Test Company")
        expect(response.body).not_to include("Other Company")
      end
    end

    describe 'GET /companies/:id' do
      it 'returns http success for companies show page' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(company.name)
      end

      it 'displays company details panel' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response.body).to include("Company Details")
        expect(response.body).to include("Test Company")
        expect(response.body).to include("Current Stage")
        expect(response.body).to include("Current Performance")
      end

      it 'displays fund investment panel' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response.body).to include("Fund Investment")
        expect(response.body).to include("Test Fund")
        expect(response.body).to include("Initial Investment")
        expect(response.body).to include("$500") # invested capital
        expect(response.body).to include("Investment Date")
      end

      it 'displays documents panel' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response.body).to include("Documents")
      end

      it 'redirects when company is not accessible' do
        # Create a company in a fund the investor doesn't have access to
        other_fund = create(:fund, firm_account: firm_account, name: "Other Fund")
        other_company = create(:company, firm_account: firm_account, name: "Other Company")
        create(:position, fund: other_fund, company: other_company, invested_capital_cents: 25000)

        switch_to_account(investor_account)
        get company_path(other_company)
        expect(response).to redirect_to(companies_path)
        follow_redirect!
        expect(response.body).to include("Company not found or access denied")
      end

      it 'returns 404 for non-existent company' do
        switch_to_account(investor_account)
        get company_path(999999)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to sign in for companies index' do
        get companies_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to sign in for companies show' do
        get company_path(company)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with company locations' do
      let!(:location) { create(:location, city: "San Francisco", region: "CA", country: "USA") }

      before do
        company.locations << location
      end

      it 'displays location information in index' do
        switch_to_account(investor_account)
        get companies_path
        expect(response.body).to include("San Francisco, CA, USA")
      end

      it 'displays location information in show page' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response.body).to include("Locations")
        expect(response.body).to include("San Francisco, CA, USA")
      end
    end

    context 'with company notes (timeline)' do
      let!(:company_note) { create(:company_note, company: company, active: true, note: "Great progress this quarter", created_at: 1.week.ago) }

      it 'displays timeline in show page' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response.body).to include("Timeline")
        expect(response.body).to include("Great progress this quarter")
      end
    end

    context 'with company documents' do
      let!(:document) { create(:document, company: company, name: "Company Financials", date: Date.current) }

      it 'displays documents in show page' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Company Financials")
        expect(response.body).to include("Download")
      end
    end

    context 'with current assets' do
      let!(:asset) { create(:asset, position: position, asset_type: :EQUITY, quantity: 1000, current: true) }

      it 'displays current assets in show page' do
        switch_to_account(investor_account)
        get company_path(company)
        expect(response.body).to include("Current Assets")
        expect(response.body).to include("EQUITY")
        expect(response.body).to include("1000")
      end
    end
  end
end

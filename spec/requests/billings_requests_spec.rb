require "rails_helper"

RSpec.describe "Billings", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:plan) { create(:plan, activated_at: Time.current, position: 1) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  before do
    stub_request(:post, "https://api.stripe.com/v1/setup_intents")
      .to_return(
        status: 200,
        body: {
          id: "seti_MOCK#{SecureRandom.alphanumeric(14)}",
          client_secret: "seti_MOCK#{SecureRandom.alphanumeric(14)}_secret_#{SecureRandom.alphanumeric(14)}"
        }.to_json, headers: {
          "Content-Type" => "application/json"
        }
      )
  end

  context "when checking the billings pages" do
    let!(:user) { create(:user, :confirmed) }

    describe "GET /plan" do
      it "returns http success" do
        sign_in user
        account = user.personal_account
        get plan_settings_billings_path(account)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /overview" do
      it "returns http success" do
        sign_in user
        account = user.personal_account
        get overview_settings_billings_path(account)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /payment_methods" do
      it "returns http success" do
        sign_in user
        account = user.personal_account
        get settings_payment_methods_path(account)
        expect(response).to have_http_status(:success)
      end
    end
  end
end

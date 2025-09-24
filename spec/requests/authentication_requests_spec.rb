require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:plan) { create(:plan, activated_at: Time.current, position: 1) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  describe 'Devise sign up' do
    let(:valid_params) { { user: { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' } } }
    let(:invalid_params) { { user: { email: '', password: '', password_confirmation: '' } } }

    it 'registers a new user with valid params' do
      post user_registration_path, params: valid_params
      expect(response).to redirect_to(root_path)
    end

    it 'shows errors with invalid params' do
      post user_registration_path, params: invalid_params
      expect(response.body).to include('error')
    end
  end

  describe 'Devise sign in' do
    let!(:user) { create(:user, :confirmed) }
    let(:valid_params) { { user: { email: user.email, password: 'password123' } } }
    let(:invalid_params) { { user: { email: user.email, password: 'wrongpass' } } }

    it 'signs in with valid credentials' do
      post user_session_path, params: valid_params
      expect(response).to redirect_to(dashboard_path)
    end

    it 'shows errors with invalid credentials' do
      post user_session_path, params: invalid_params
      expect(response.body).to include('Invalid')
    end
  end

  describe 'Authenticated dashboard root' do
    let!(:user) { create(:user, :confirmed) }

    it 'redirects authenticated user to /dashboard' do
      sign_in user
      get dashboard_path
      expect(response).to have_http_status(:success)
    end
  end
end

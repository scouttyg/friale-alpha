require 'rails_helper'

RSpec.describe 'Authentication', type: :feature do

  before do
    # Create the free plan
    free_plan = create(:plan, name: 'Free', position: 1)
    create(:plan_period, plan: free_plan, interval: 'MONTH', stripe_price_id: 'price_mock_123')

    # Stub Stripe subscription creation
    allow(Stripe::Subscription).to receive(:create).and_return(
      instance_double("Stripe::Subscription", id: "sub_mock_123")
    )
  end

  context 'when signing up' do
    let(:email) { Faker::Internet.email }
    let(:password) { SecureRandom.uuid }

    it 'allows the user to sign up and be redirected correctly to their dashboard' do
      visit new_user_registration_path

      expect do
        fill_in 'user_email', with: email
        fill_in 'user_password', with: password
        fill_in 'user_password_confirmation', with: password

        click_button 'Sign up'
      end.to change(User, :count).by(1)

      expect(page).to have_current_path(data_requests_path)
      expect(page.status_code).to eq 200
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts page.html
      raise e
    end
  end

  context 'when signing in' do
    let(:email) { Faker::Internet.email }
    let(:password) { SecureRandom.uuid }

    before do
      create(:user, email: email, password: password, password_confirmation: password)
    end

    it 'allows the user to sign in and be redirected correctly to their dashboard' do
      visit new_user_session_path

      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      click_button 'Sign in'

      expect(page).to have_current_path(data_requests_path)
      expect(page.status_code).to eq 200
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts page.html
      raise e
    end
  end
end

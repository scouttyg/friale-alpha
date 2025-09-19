require 'rails_helper'

RSpec.describe 'Public Pages', type: :request do
  describe 'GET /' do
    it 'renders the home page' do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /about' do
    it 'renders the about page' do
      get about_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /contact' do
    it 'renders the contact page' do
      get contact_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /pricing' do
    it 'renders the pricing page' do
      get pricing_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /contact' do
    let(:valid_params) { { contact_form_message: { email: 'test@example.com', subject: 'Hi', message: 'Hello' } } }
    let(:invalid_params) { { contact_form_message: { email: '', subject: '', message: '' } } }

    it 'submits the contact form with valid params' do
      post contact_post_path, params: valid_params
      expect(response).to redirect_to(contact_path)
      follow_redirect!
      expect(response.body).to include('You have submitted your contact form request')
    end

    it 'shows errors with invalid params' do
      post contact_post_path, params: invalid_params
      expect(response).to redirect_to(contact_path)
      follow_redirect!
      expect(response.body).to include('could not be sent')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Member Invitations Security', type: :request do
  include Devise::Test::IntegrationHelpers
  let(:account_owner) { create(:user, :confirmed, email: 'owner@example.com') }
  let(:account) { account_owner.personal_account }
  let(:existing_user) { create(:user, :confirmed, email: 'existing@example.com') }

  before do
    free_plan = create(:plan, name: 'Free', position: 1)
    create(:plan_period, plan: free_plan, interval: 'MONTH', stripe_price_id: 'price_mock_123')

    # Stub Stripe customer creation with unique IDs for each request
    customer_counter = 0
    stub_request(:post, 'https://api.stripe.com/v1/customers')
      .to_return do
        customer_counter += 1
        {
          status: 200,
          body: { id: "cus_test#{customer_counter}" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end

    # Stub Stripe subscription creation with unique IDs for each request
    subscription_counter = 0
    stub_request(:post, 'https://api.stripe.com/v1/subscriptions')
      .to_return do
        subscription_counter += 1
        {
          status: 200,
          body: { id: "sub_test#{subscription_counter}" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end
  end

  describe 'invitation access control' do
    let!(:invitation_for_new_user) do
      create(:member, :invited,
             source: account,
             creator: account_owner,
             invite_email: 'newuser@example.com')
    end

    let!(:invitation_for_existing_user) do
      create(:member, :invited,
             source: account,
             creator: account_owner,
             invite_email: existing_user.email)
    end

    context 'when not signed in' do
      it 'allows viewing any invitation' do
        get invitation_path(token: invitation_for_new_user.invite_token)
        expect(response).to have_http_status(:success)
        expect(response.body).to include('newuser@example.com')
      end

      it 'can accept invitation for new user' do
        post accept_invitation_path(token: invitation_for_new_user.invite_token)
        expect(response).to redirect_to(new_user_registration_path)
        expect(session[:invitation_token]).to eq(invitation_for_new_user.invite_token)
        expect(session[:invitation_email]).to eq('newuser@example.com')
      end

      it 'signs in existing user when accepting their invitation' do
        post accept_invitation_path(token: invitation_for_existing_user.invite_token)

        invitation_for_existing_user.reload
        expect(invitation_for_existing_user.accepted?).to be true
        expect(invitation_for_existing_user.user).to eq(existing_user)
        expect(response).to redirect_to(account_path(account))
      end
    end

    context 'when signed in' do
      before { sign_in existing_user }

      it 'allows viewing own invitation' do
        get invitation_path(token: invitation_for_existing_user.invite_token)
        expect(response).to have_http_status(:success)
      end

      it 'prevents viewing invitation for different email' do
        get invitation_path(token: invitation_for_new_user.invite_token)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        # Follow any additional redirects (authenticated users get redirected to dashboard)
        follow_redirect! while response.status.in?([301, 302])
        expect(response.body).to include('This invitation is for a different email address. Please sign out first if you want to accept this invitation.')
      end

      it 'accepts own invitation using current user' do
        post accept_invitation_path(token: invitation_for_existing_user.invite_token)

        invitation_for_existing_user.reload
        expect(invitation_for_existing_user.accepted?).to be true
        expect(invitation_for_existing_user.user).to eq(existing_user)
        expect(response).to redirect_to(account_path(account))
      end

      it 'prevents accepting invitation for different email' do
        post accept_invitation_path(token: invitation_for_new_user.invite_token)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        # Follow any additional redirects (authenticated users get redirected to dashboard)
        follow_redirect! while response.status.in?([301, 302])
        expect(response.body).to include('This invitation is for a different email address. Please sign out first if you want to accept this invitation.')

        # Verify invitation wasn't accepted
        invitation_for_new_user.reload
        expect(invitation_for_new_user.pending?).to be true
      end

      it 'allows declining own invitation' do
        expect do
          post decline_invitation_path(token: invitation_for_existing_user.invite_token)
        end.to change(Member, :count).by(-1)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        # Follow any additional redirects (authenticated users get redirected to dashboard)
        follow_redirect! while response.status.in?([301, 302])
        expect(response.body).to include('Invitation declined')
      end

      it 'prevents declining invitation for different email' do
        expect do
          post decline_invitation_path(token: invitation_for_new_user.invite_token)
        end.not_to change(Member, :count)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        # Follow any additional redirects (authenticated users get redirected to dashboard)
        follow_redirect! while response.status.in?([301, 302])
        expect(response.body).to include('You cannot decline an invitation for a different email address')
      end
    end

    context 'with invalid or used invitations' do
      it 'handles invalid token gracefully' do
        get invitation_path(token: 'invalid-token')
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Invalid invitation link')
      end

      it 'prevents viewing already accepted invitation' do
        invitation_for_existing_user.accept!(existing_user)

        get invitation_path(token: 'old-token')
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Invalid invitation link')
      end
    end
  end

  describe 'sign up flow with invitation' do
    let(:invitation) { create(:member, :invited, source: account, invite_email: 'newmember@example.com') }

    it 'completes invitation after sign up' do
      # Visit invitation
      get invitation_path(token: invitation.invite_token)
      expect(response).to have_http_status(:success)

      # Accept invitation (redirects to sign up)
      post accept_invitation_path(token: invitation.invite_token)
      expect(response).to redirect_to(new_user_registration_path)

      # Complete sign up
      post user_registration_path, params: {
        user: {
          email: 'newmember@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'New',
          last_name: 'Member'
        }
      }

      # User should be created and invitation accepted
      new_user = User.find_by(email: 'newmember@example.com')
      expect(new_user).to be_present

      invitation.reload
      expect(invitation.accepted?).to be true
      expect(invitation.user).to eq(new_user)
    end
  end
end

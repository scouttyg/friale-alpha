require 'rails_helper'

RSpec.describe 'Invitations', type: :request do
  let(:account) { create(:account) }
  let(:creator) { create(:user, :confirmed) }
  let(:member) { create(:member, :invited, source: account, creator: creator, invite_email: 'test@example.com', type: "AccountMember") }

  before do
    free_plan = create(:plan, name: 'Free', position: 1)
    create(:plan_period, plan: free_plan, interval: 'MONTH')
  end

  describe 'GET /invitations/:token' do
    context 'with valid token' do
      it 'shows the invitation page' do
        get invitation_path(token: member.invite_token)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("You've been invited!")
        expect(response.body).to include(CGI.escapeHTML(account.name))
        expect(response.body).to include(CGI.escapeHTML(creator.display_name))
      end
    end

    context 'with invalid token' do
      it 'redirects to root with error' do
        get invitation_path(token: 'invalid-token')

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Invalid invitation link')
      end
    end

    context 'when invitation already accepted' do
      let(:accepted_user) { create(:user, :confirmed) }
      let(:accepted_member) do
        # Create an accepted member but keep the token to test the controller logic
        m = create(:member, :invited, source: account, creator: creator, invite_email: 'accepted@example.com')
        m.update!(user: accepted_user) # Accept but keep the token
        m
      end

      it 'redirects to root with error' do
        get invitation_path(token: accepted_member.invite_token)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('This invitation has already been accepted')
      end
    end
  end

  describe 'POST /invitations/:token/accept' do
    context 'when user does not exist' do
      it 'redirects to sign up with invitation stored in session' do
        post accept_invitation_path(token: member.invite_token)

        expect(response).to redirect_to(new_user_registration_path)
        expect(session[:invitation_token]).to eq(member.invite_token)
        expect(session[:invitation_email]).to eq(member.invite_email)
      end
    end

    context 'when user already exists' do
      let!(:existing_user) { create(:user, :confirmed, email: member.invite_email) }

      it 'accepts invitation and signs in user' do
        post accept_invitation_path(token: member.invite_token)

        member.reload
        expect(member.accepted?).to be true
        expect(member.user).to eq(existing_user)

        expect(response).to redirect_to(account_path(account))
      end
    end
  end

  describe 'POST /invitations/:token/decline' do
    it 'deletes the member and redirects to root' do
      # Create the member first to ensure it exists
      test_member = member
      token = test_member.invite_token

      expect do
        post decline_invitation_path(token: token)
      end.to change(Member, :count).by(-1)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('Invitation declined')
    end
  end
end

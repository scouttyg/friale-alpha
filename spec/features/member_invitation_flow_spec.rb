require 'rails_helper'

RSpec.describe 'Member Invitation Flow', type: :feature do
  let(:account_owner) { create(:user, first_name: 'Account', last_name: 'Owner') }
  let(:account) { account_owner.personal_account }
  
  before do
    # Ensure the account has proper setup
    account.reload
  end

  describe 'Inviting a new member' do
    before do
      sign_in account_owner
      visit settings_members_path(account)
    end

    it 'allows account owner to invite a new member' do
      click_link 'New Member'
      
      fill_in 'Email', with: 'newmember@example.com'
      select 'Collaborator', from: 'Access level'
      
      expect {
        click_button 'Create Account member'
      }.to change(Member, :count).by(1)
      
      expect(page).to have_content('Member invited successfully')
      expect(page).to have_content('newmember@example.com')
      expect(page).to have_content('Pending Invitation')
      
      # Check that invitation email was sent
      member = Member.last
      expect(member.invite_email).to eq('newmember@example.com')
      expect(member.invite_token).to be_present
      expect(member.creator).to eq(account_owner)
    end
  end

  describe 'Accepting an invitation' do
    let!(:member) { create(:member, 
                          source: account, 
                          creator: account_owner,
                          invite_email: 'invited@example.com',
                          access_level: 'collaborator') }

    context 'when user does not have an account' do
      it 'guides user through sign up process' do
        visit invitation_path(token: member.invite_token)
        
        expect(page).to have_content("You've been invited!")
        expect(page).to have_content(account.name)
        expect(page).to have_content('Collaborator')
        expect(page).to have_content(account_owner.display_name)
        
        click_button 'Accept Invitation'
        
        # Should be redirected to sign up
        expect(page).to have_content('Please create your account to complete the invitation')
        expect(page).to have_field('Email', with: 'invited@example.com')
        
        # Complete sign up
        fill_in 'First name', with: 'New'
        fill_in 'Last name', with: 'Member'
        fill_in 'Password', with: 'password123'
        fill_in 'Password confirmation', with: 'password123'
        
        click_button 'Sign up'
        
        # Should be signed in and added to the account
        expect(page).to have_content('Account created successfully! Welcome to the team.')
        
        # Verify member was updated
        member.reload
        expect(member.accepted?).to be true
        expect(member.user.email).to eq('invited@example.com')
        expect(member.invite_token).to be_nil
        expect(member.invite_email).to be_nil
      end
    end

    context 'when user already has an account' do
      let!(:existing_user) { create(:user, email: 'invited@example.com', password: 'password123') }

      it 'adds user to the account immediately' do
        visit invitation_path(token: member.invite_token)
        
        click_button 'Accept Invitation'
        
        # Should be signed in and added to the account
        expect(page).to have_content('Invitation accepted! Welcome to the team.')
        expect(current_path).to eq(account_path(account))
        
        # Verify member was updated
        member.reload
        expect(member.accepted?).to be true
        expect(member.user).to eq(existing_user)
      end
    end

    context 'when invitation has already been accepted' do
      before do
        member.accept!(create(:user))
      end

      it 'shows error message' do
        visit invitation_path(token: member.reload.invite_token || 'old-token')
        
        expect(page).to have_content('This invitation has already been accepted')
      end
    end

    context 'with invalid invitation token' do
      it 'shows error message' do
        visit invitation_path(token: 'invalid-token')
        
        expect(page).to have_content('Invalid invitation link')
      end
    end
  end

  describe 'Declining an invitation' do
    let!(:member) { create(:member, 
                          source: account, 
                          creator: account_owner,
                          invite_email: 'invited@example.com') }

    it 'allows user to decline invitation' do
      visit invitation_path(token: member.invite_token)
      
      expect {
        click_button 'Decline'
      }.to change(Member, :count).by(-1)
      
      expect(page).to have_content('Invitation declined')
      expect(current_path).to eq(root_path)
    end
  end
end
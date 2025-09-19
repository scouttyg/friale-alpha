require 'rails_helper'

RSpec.describe Member, type: :model do
  include ActiveJob::TestHelper
  let(:account) { create(:account) }
  let(:creator) { create(:user, :confirmed) }

  before do
    # Clear ActionMailer deliveries and jobs before each test
    ActionMailer::Base.deliveries.clear
    clear_enqueued_jobs
    free_plan = create(:plan, name: 'Free', position: 1)
    create(:plan_period, plan: free_plan, interval: 'MONTH', stripe_price_id: 'price_mock_123')

    # Stub Stripe customer creation with unique IDs for each request
    customer_counter = 0
    WebMock.stub_request(:post, 'https://api.stripe.com/v1/customers')
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
    WebMock.stub_request(:post, 'https://api.stripe.com/v1/subscriptions')
      .to_return do
        subscription_counter += 1
        {
          status: 200,
          body: { id: "sub_test#{subscription_counter}" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end
  end

  describe 'validations' do
    it 'requires invite_email when user_id is not present' do
      member = Member.new(source: account, creator: creator)
      expect(member).not_to be_valid
      expect(member.errors[:invite_email]).to include("can't be blank")
    end

    it 'validates email format' do
      member = Member.new(source: account, creator: creator, invite_email: 'invalid-email')
      expect(member).not_to be_valid
      expect(member.errors[:invite_email]).to include('is invalid')
    end

    it 'does not require invite_email when user is present' do
      user = create(:user, :confirmed)
      member = Member.new(source: account, creator: creator, user: user)
      expect(member).to be_valid
    end
  end

  describe 'callbacks' do
    it 'generates invite_token before create when invite_email is present' do
      member = Member.new(source: account, creator: creator, invite_email: 'test@example.com')
      expect(member.invite_token).to be_nil
      member.save!
      expect(member.invite_token).to be_present
      expect(member.invite_token.length).to be >= 32
    end

    it 'does not generate invite_token when user is present' do
      user = create(:user, :confirmed)
      member = Member.new(source: account, creator: creator, user: user)
      member.save!
      expect(member.invite_token).to be_nil
    end

    it 'sends invitation email after create when invite_email is present' do
      # Test that the job is enqueued
      expect do
        Member.create!(source: account, creator: creator, invite_email: 'test@example.com')
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with('MemberMailer', 'invitation_email', 'deliver_now', args: [an_instance_of(Member)])
    end

    it 'does not send invitation email when user is present' do
      user = create(:user, :confirmed)
      expect do
        Member.create!(source: account, creator: creator, user: user)
      end.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  describe 'scopes' do
    let!(:invited_member) { create(:member, source: account, invite_email: 'invited@example.com') }
    let!(:accepted_member) { create(:member, source: account, user: create(:user, :confirmed)) }

    it 'returns invited members' do
      expect(Member.invited).to include(invited_member)
      expect(Member.invited).not_to include(accepted_member)
    end

    it 'returns accepted members' do
      expect(Member.accepted).to include(accepted_member)
      expect(Member.accepted).not_to include(invited_member)
    end

    it 'returns pending members' do
      expect(Member.pending).to include(invited_member)
      expect(Member.pending).not_to include(accepted_member)
    end
  end

  describe '#pending?' do
    it 'returns true when invite_email is present and user_id is blank' do
      member = Member.new(source: account, invite_email: 'test@example.com')
      expect(member.pending?).to be true
    end

    it 'returns false when user_id is present' do
      member = Member.new(source: account, user: create(:user, :confirmed))
      expect(member.pending?).to be false
    end
  end

  describe '#accepted?' do
    it 'returns true when user_id is present' do
      member = Member.new(source: account, user: create(:user, :confirmed))
      expect(member.accepted?).to be true
    end

    it 'returns false when user_id is blank' do
      member = Member.new(source: account, invite_email: 'test@example.com')
      expect(member.accepted?).to be false
    end
  end

  describe '#accept!' do
    let(:member) { create(:member, source: account, invite_email: 'test@example.com', creator: creator) }
    let(:user) { create(:user, :confirmed, email: 'test@example.com') }

    it 'associates the member with the user and clears invitation data' do
      member.accept!(user)
      member.reload

      expect(member.user).to eq(user)
      expect(member.invite_email).to be_nil
      expect(member.invite_token).to be_nil
    end
  end
end

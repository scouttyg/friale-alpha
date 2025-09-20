require 'rails_helper'

RSpec.describe MemberMailer, type: :mailer do
  let!(:plan) { create(:plan, activated_at: Time.current, position: 1, member_limit: 10) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  before do
    # Stub Stripe customer creation for any email
    stub_request(:post, 'https://api.stripe.com/v1/customers')
      .to_return(status: 200, body: { id: 'cus_test123' }.to_json, headers: { 'Content-Type' => 'application/json' })
    # Stub Stripe subscription creation
    stub_request(:post, 'https://api.stripe.com/v1/subscriptions')
      .to_return(status: 200, body: { id: 'sub_test123' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  let(:account) { create(:account) }
  let(:creator) { create(:user, :confirmed) }
  let(:member) { create(:member, :invited, source: account, creator: creator, invite_email: 'test@example.com', type: "AccountMember") }

  describe 'invitation_email' do
    let(:mail) { described_class.invitation_email(member) }

    it 'does not error when being sent' do
      expect { mail.deliver_now }.not_to raise_error
    end
  end
end

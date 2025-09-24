require 'rails_helper'

RSpec.describe MemberMailer, type: :mailer do
  let!(:plan) { create(:plan, activated_at: Time.current, position: 1, member_limit: 10) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

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

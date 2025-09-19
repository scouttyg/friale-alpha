# == Schema Information
#
# Table name: accounts
#
#  id                 :bigint           not null, primary key
#  name               :string
#  slug               :string
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      account = build(:account)
      expect(account).to be_valid
    end

    it 'is not valid without a name' do
      account = build(:account, name: nil)
      expect(account).not_to be_valid
    end

    it 'requires a unique name' do
      create(:account, name: 'Test Account')
      duplicate_account = build(:account, name: 'Test Account')
      expect(duplicate_account).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'creates a Stripe customer after creation' do
      account = create(:account)
      expect(account.stripe_customer_id).not_to be_nil
    end
  end

  describe 'type checks' do
    it 'identifies personal accounts' do
      account = create(:account, type: 'PersonalAccount')
      expect(account).to be_personal
    end
  end

  describe '#initials' do
    it 'returns correct initials for the account name' do
      account = build(:account, name: 'Test Account')
      expect(account.initials).to eq('TA')
    end
  end
end

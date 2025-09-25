# == Schema Information
#
# Table name: accounts
#
#  id                 :bigint           not null, primary key
#  metadata           :jsonb
#  name               :string
#  slug               :string
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string
#
# Indexes
#
#  index_accounts_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#
FactoryBot.define do
  factory :account do
    name { Faker::Company.name }
    type { 'Account' }
    sequence(:stripe_customer_id) { |n| "cus_MOCK#{n}#{Faker::Alphanumeric.alphanumeric(number: 14)}" }

    # Create owner member after account is created
    after(:create) do |account, context|
      unless account.members.exists?
        owner_user = create(:user, :confirmed, :skip_account_setup)
        create(:account_member, :owner, source: account, user: owner_user, creator: owner_user)
      end
    end

    trait :with_subscription do
      after(:create) do |account, context|
        create(:subscription, account: account) unless account.subscription
      end
    end
  end

  factory :personal_account, class: 'PersonalAccount', parent: :account do
    name { Faker::Name.name }
    type { 'PersonalAccount' }
    stripe_customer_id { "cus_MOCK#{Faker::Alphanumeric.alphanumeric(number: 14)}" }

    # Create owner member after account is created
    after(:create) do |account, context|
      unless account.members.exists?
        owner_user = create(:user, :confirmed, :skip_account_setup)
        create(:account_member, :owner, source: account, user: owner_user, creator: owner_user)
      end
    end

    trait :with_subscription do
      after(:create) do |account, context|
        create(:subscription, account: account) unless account.subscription
      end
    end
  end

  factory :firm_account, class: 'FirmAccount', parent: :account do
    name { Faker::Name.name }
    type { 'FirmAccount' }
    stripe_customer_id { "cus_MOCK#{Faker::Alphanumeric.alphanumeric(number: 14)}" }

    # Create owner member after account is created
    after(:create) do |account, context|
      unless account.members.exists?
        owner_user = create(:user, :confirmed, :skip_account_setup)
        create(:account_member, :owner, source: account, user: owner_user, creator: owner_user)
      end
    end

    trait :with_subscription do
      after(:create) do |account, context|
        create(:subscription, account: account) unless account.subscription
      end
    end
  end

  factory :investor_account, class: 'InvestorAccount', parent: :account do
    name { Faker::Name.name }
    type { 'InvestorAccount' }
    stripe_customer_id { "cus_MOCK#{Faker::Alphanumeric.alphanumeric(number: 14)}" }

    # Create owner member after account is created
    after(:create) do |account, context|
      unless account.members.exists?
        owner_user = create(:user, :confirmed, :skip_account_setup)
        create(:account_member, :owner, source: account, user: owner_user, creator: owner_user)
      end
    end

    trait :with_subscription do
      after(:create) do |account, context|
        create(:subscription, account: account) unless account.subscription
      end
    end
  end
end

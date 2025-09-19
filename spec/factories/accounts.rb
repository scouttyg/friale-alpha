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
FactoryBot.define do
  factory :account do
    name { Faker::Company.name }
    type { 'Account' }
    stripe_customer_id { "cus_#{Faker::Alphanumeric.alphanumeric(number: 14)}" }
  end

  factory :personal_account, class: 'PersonalAccount', parent: :account do
    type { 'PersonalAccount' }
  end

  factory :team_account, class: 'TeamAccount', parent: :account do
    type { 'TeamAccount' }
  end
end

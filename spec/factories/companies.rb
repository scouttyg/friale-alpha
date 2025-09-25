# == Schema Information
#
# Table name: companies
#
#  id              :bigint           not null, primary key
#  description     :text
#  name            :string
#  website         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  firm_account_id :bigint
#
# Indexes
#
#  index_companies_on_firm_account_id  (firm_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (firm_account_id => accounts.id)
#
FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    website { Faker::Internet.url }
    description { Faker::Lorem.sentence }
    firm_account
    locations { [] }
  end
end

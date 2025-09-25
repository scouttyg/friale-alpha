# == Schema Information
#
# Table name: funds
#
#  id              :bigint           not null, primary key
#  name            :string
#  slug            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  firm_account_id :bigint
#
# Indexes
#
#  index_funds_on_firm_account_id  (firm_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (firm_account_id => accounts.id)
#
FactoryBot.define do
  factory :fund do
    name { "MyString" }
    slug { "MyString" }
    firm_account
  end
end

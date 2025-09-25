# == Schema Information
#
# Table name: fund_distributions
#
#  id              :bigint           not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  date            :date
#  name            :string
#  notes           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  fund_id         :bigint           not null
#  position_id     :bigint
#
# Indexes
#
#  index_fund_distributions_on_fund_id      (fund_id)
#  index_fund_distributions_on_position_id  (position_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (position_id => positions.id)
#
FactoryBot.define do
  factory :fund_distribution do
    name { Faker::Lorem.sentence }
    date { Date.today }
    amount { 1_000_000  }
    notes { Faker::Lorem.sentence }
    fund
    position
  end
end

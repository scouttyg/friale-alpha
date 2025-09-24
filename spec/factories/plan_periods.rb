# == Schema Information
#
# Table name: plan_periods
#
#  id              :bigint           not null, primary key
#  interval        :integer
#  price_cents     :integer          default(0), not null
#  price_currency  :string           default("USD"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  plan_id         :bigint           not null
#  stripe_price_id :string           not null
#
# Indexes
#
#  index_plan_periods_on_plan_id          (plan_id)
#  index_plan_periods_on_stripe_price_id  (stripe_price_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#
FactoryBot.define do
  factory :plan_period do
    association :plan
    interval { :MONTH }
    sequence(:stripe_price_id) { |n| "price_MOCK#{n}#{Faker::Alphanumeric.alphanumeric(number: 14)}" }
  end
end

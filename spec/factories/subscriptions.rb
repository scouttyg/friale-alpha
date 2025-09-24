# == Schema Information
#
# Table name: subscriptions
#
#  id                     :bigint           not null, primary key
#  usage_limits           :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :bigint           not null
#  plan_id                :bigint           not null
#  plan_period_id         :bigint           not null
#  stripe_subscription_id :string
#
# Indexes
#
#  index_subscriptions_on_account_id              (account_id)
#  index_subscriptions_on_plan_id                 (plan_id)
#  index_subscriptions_on_plan_period_id          (plan_period_id)
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (plan_period_id => plan_periods.id)
#

FactoryBot.define do
  factory :subscription do
    association :account
    association :plan
    plan_period { association(:plan_period, plan: plan) }
    usage_limits { {} }
    stripe_subscription_id { "sub_#{Faker::Alphanumeric.alphanumeric(number: 14)}" }
  end
end

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

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

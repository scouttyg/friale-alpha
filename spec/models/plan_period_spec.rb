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
require 'rails_helper'

RSpec.describe PlanPeriod, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

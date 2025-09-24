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
class PlanPeriod < ApplicationRecord
  monetize :price_cents
  belongs_to :plan

  enum :interval, {
    MONTH: 1,
    YEAR: 12
  }, validate: true

  validates :interval, presence: true
  validates :stripe_price_id, presence: true, uniqueness: true, format: { with: /\Aprice_[a-zA-Z0-9]+\z/ }

  validates :price_cents, presence: true, numericality: {
    greater_than_or_equal_to: 0
  }

  def name
    "#{plan.name} - #{interval}"
  end

  def stripe_price
    Stripe::Price.retrieve(stripe_price_id)
  end
end

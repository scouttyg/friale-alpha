# == Schema Information
#
# Table name: plans
#
#  id                :bigint           not null, primary key
#  activated_at      :datetime
#  deactivated_at    :datetime
#  description       :text
#  name              :string
#  position          :integer
#  usage_limits      :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stripe_product_id :string
#
class Plan < ApplicationRecord
  include StoreAccessorWithCasting
  positioned

  LIMIT_TYPES = {
    member_limit: {
      name: 'Member Limit',
      model: Member,
      type: :integer,
      limit_type: :hard
    }
  }.freeze

  LIMIT_ATTRIBUTES_AND_TYPES = LIMIT_TYPES.transform_values { |value| value[:type] }.freeze
  store_accessor_with_casting :usage_limits, LIMIT_ATTRIBUTES_AND_TYPES

  has_many :plan_periods, -> { order(price_cents: :asc) }, dependent: :destroy, inverse_of: :plan
  has_many :subscriptions, dependent: :restrict_with_exception

  scope :deactivated_after, ->(time) { where.not(deactivated_at: nil).where('deactivated_at >= ?', time) }
  scope :deactivated_before, ->(time) { where.not(deactivated_at: nil).where('deactivated_at < ?', time) }
  scope :deactivated, -> { deactivated_before(Time.current) }
  scope :not_deactivated, -> { where(deactivated_at: nil).or(deactivated_after(Time.current)) }

  scope :activated_after, ->(time) { where.not(activated_at: nil).where('activated_at >= ?', time) }
  scope :activated_before, ->(time) { where.not(activated_at: nil).where('activated_at < ?', time) }
  scope :activated, -> { activated_before(Time.current) }
  scope :not_activated, -> { where(activated_at: nil).or(activated_after(Time.current)) }

  scope :active, -> { activated.not_deactivated.order(position: :asc) }

  after_initialize :set_default_usage_limits

  validates :name, presence: true
  validates :stripe_product_id, presence: true, uniqueness: true

  def activate!
    update!(activated_at: Time.current)
  end

  def deactivate!
    update!(deactivated_at: Time.current)
  end

  def active?
    activated? && !deactivated?
  end

  def activated?
    return false if activated_at.blank?

    activated_at <= Time.current
  end

  def deactivated?
    return false if deactivated_at.blank?

    deactivated_at < Time.current
  end

  def stripe_plan
    Stripe::Product.retrieve(stripe_product_id)
  end

  def self.import_from_stripe!(force: false)
    Plans::Stripe::Importer.import!(reorder: true, force: force)
  end

  def self.reorder_plans!
    updated_plan_ids = []

    PlanPeriod.where(interval: :MONTH).order(price_cents: :asc).each.with_index(1) do |plan_period, current_index|
      plan = plan_period.plan
      next if updated_plan_ids.include?(plan.id)

      plan.update(position: current_index) if plan.position.nil?
    end
  end

  private

  def set_default_usage_limits
    self.class::LIMIT_ATTRIBUTES_AND_TYPES.each do |attrib, type|
      next unless type == :integer

      self.send("#{attrib}=", 0) if self.send(attrib).nil?
    end
  end
end

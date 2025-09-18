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
class Account < ApplicationRecord
  extend FriendlyId
  has_paper_trail

  friendly_id :name, use: :slugged

  has_many :members, as: :source, class_name: "AccountMember", dependent: :destroy
  has_one :member_owner, -> { owner }, as: :source, class_name: "AccountMember", inverse_of: :source, dependent: :destroy

  has_many :users, through: :members
  has_one :owner, through: :member_owner, source: :user

  has_one :subscription, dependent: :destroy
  has_one :plan, through: :subscription
  has_one :plan_period, through: :subscription

  has_many :payment_methods, dependent: :destroy
  has_many :active_payment_methods, -> { active }, class_name: "PaymentMethod", dependent: :destroy, inverse_of: :account
  has_many :inactive_payment_methods, -> { inactive }, class_name: "PaymentMethod", dependent: :destroy, inverse_of: :account

  has_one :default_payment_method, -> { active.default_first }, class_name: "PaymentMethod", dependent: :destroy, inverse_of: :account
  has_one_attached :avatar

  validates :name, presence: true, uniqueness: true

  after_create :ensure_stripe_customer

  def personal?
    type == "PersonalAccount"
  end

  def initials
    name.split(" ").map(&:first).join.upcase
  end

  private

  def ensure_stripe_customer
    return if stripe_customer_id.present?

    customer = Stripe::Customer.create(email: owner.email, name: name, metadata: { account_id: id })
    update!(stripe_customer_id: customer.id)
  rescue Stripe::StripeError => e
    Rails.logger.error "[#{self.class.name}] Failed to create Stripe customer for account #{id}: #{e.message}"
    raise
  end
end

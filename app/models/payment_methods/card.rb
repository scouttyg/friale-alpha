# == Schema Information
#
# Table name: payment_methods
#
#  id                       :bigint           not null, primary key
#  default                  :boolean          default(FALSE)
#  deleted_at               :datetime
#  metadata                 :jsonb
#  type                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :bigint           not null
#  stripe_payment_method_id :string           not null
#
# Indexes
#
#  index_payment_methods_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Card < PaymentMethod
  CARD_BRANDS = [
    "visa",
    "mastercard",
    "american_express",
    "discover",
    "diners_club"
  ]

  store_accessor :metadata, :brand, :exp_month, :exp_year

  validates :brand, presence: true, inclusion: { in: CARD_BRANDS }
  validates :last_four, presence: true, format: { with: /\A\d{4}\z/, message: "must be exactly 4 digits" }
  validates :exp_month, presence: true, numericality: { in: 1..12 }
  validates :exp_year, presence: true, numericality: { greater_than_or_equal_to: (Time.current.year - 10), less_than_or_equal_to: (Time.current.year + 10) }

  def self.model_name
    PaymentMethod.model_name
  end

  def display_details
    "#{brand.titleize} •••• #{last_four}"
  end

  def expired?
    return false if exp_year.nil? || exp_month.nil?

    expiration_date = Date.new(exp_year.to_i, exp_month.to_i).end_of_month
    expiration_date < Date.current
  end
end

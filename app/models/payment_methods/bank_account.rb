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
#  index_payment_methods_on_account_id                (account_id)
#  index_payment_methods_on_stripe_payment_method_id  (stripe_payment_method_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class BankAccount < PaymentMethod
  store_accessor :metadata, :bank_name, :owner_name, :account_number, :routing_number, :address, :notes

  validates :bank_name, presence: true
  validates :owner_name, presence: true
  validates :account_number, presence: true, format: { with: /\A\d{9,17}\z/, message: "must be between 9 and 17 digits" }
  validates :routing_number, presence: true, format: { with: /\A\d{9}\z/, message: "must be exactly 9 digits" }

  def display_details
    "#{bank_name} •••• #{account_number}"
  end
end

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
class PaymentMethod < ApplicationRecord
  belongs_to :account

  # Common attributes shared by all payment methods
  store_accessor :metadata, :last_four

  # Validations
  validates :stripe_payment_method_id, presence: true, uniqueness: true
  validates :type, presence: true
  validates :last_four, presence: true

  # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :default_first, -> { order(default: :desc) }

  # Default management
  def mark_as_default!
    PaymentMethod.transaction do
      account.payment_methods.where(default: true).update_all(default: false)
      update!(default: true)
    end
  end

  # Soft deletion
  def soft_delete!
    update!(deleted_at: Time.current, default: false)
  end

  # Display
  def display_name
    parts = []
    parts << display_details if respond_to?(:display_details)
    parts << "(Default)" if default?
    parts.join(" ")
  end

  # This should be implemented by subclasses
  def display_details
    raise NotImplementedError, "#{self.class} must implement #display_details"
  end
end

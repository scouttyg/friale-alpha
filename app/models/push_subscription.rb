# == Schema Information
#
# Table name: push_subscriptions
#
#  id          :bigint           not null, primary key
#  auth_secret :string
#  endpoint    :string
#  expires_at  :datetime
#  public_key  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_push_subscriptions_on_user_id                    (user_id)
#  index_push_subscriptions_on_user_id_endpoint_and_auth  (user_id,endpoint,public_key,auth_secret) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PushSubscription < ApplicationRecord
  VALID_PUSH_DOMAINS_HASH = {
    "apple.com" => :apple,
    "googleapis.com" => :google,
    "mozaws.net" => :mozilla,
    "mozilla.com" => :mozilla,
    "windows.com" => :windows
  }.freeze

  belongs_to :user

  validates :auth_secret, :endpoint, :public_key, presence: true
  validates :endpoint, url: true
  validate :check_valid_vendor

  scope :expires_before, ->(date_time = Time.current) { where(expires_at: ...date_time) }
  scope :expires_after, ->(date_time = Time.current) { where("expires_at IS NULL OR expires_at >= ?", date_time) }

  scope :expired, -> { expires_before(Time.current) }
  scope :active, -> { expires_after(Time.current) }

  def active?
    expires_at.blank? || expires_at >= Time.current
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def vendor
    uri = Addressable::URI.parse(endpoint)

    VALID_PUSH_DOMAINS_HASH[uri&.domain] || :unknown
  end

  private

    def check_valid_vendor
      return if VALID_PUSH_DOMAINS_HASH.value?(vendor)

      errors.add(:endpoint, "Unknown vendor for endpoint, this endpoint is most likely invalid.")
    end
end

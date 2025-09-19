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
FactoryBot.define do
  factory :push_subscription do
    user
    endpoint do
      Faker::Internet.url(
        host: PushSubscription::VALID_PUSH_DOMAINS_HASH.keys.sample
      )
    end
    public_key do
      group = 'prime256v1'
      curve = OpenSSL::PKey::EC.generate(group)
      ecdh_key = curve.public_key.to_bn.to_s(2)
      Base64.urlsafe_encode64(ecdh_key)
    end
    auth_secret { Base64.urlsafe_encode64(Random.new.bytes(16)) }

    trait :invalid do
      after(:create) do |push_subscription|
        push_subscription.auth_secret = nil
        push_subscription.save!(validate: false)
      end
    end
  end
end

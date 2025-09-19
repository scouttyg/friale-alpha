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
require 'rails_helper'

RSpec.describe PushSubscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

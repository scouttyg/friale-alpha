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
#  stripe_product_id :string           not null
#
# Indexes
#
#  index_plans_on_position           (position) UNIQUE
#  index_plans_on_stripe_product_id  (stripe_product_id) UNIQUE
#
require 'rails_helper'

RSpec.describe Plan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

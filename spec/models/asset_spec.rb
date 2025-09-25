# == Schema Information
#
# Table name: assets
#
#  id                 :bigint           not null, primary key
#  asset_type         :integer
#  cap_cents          :bigint           default(0), not null
#  cap_currency       :string           default("USD"), not null
#  current            :boolean
#  discount           :integer
#  origination        :integer
#  quantity           :decimal(10, 2)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  converted_asset_id :bigint
#  position_id        :bigint           not null
#
# Indexes
#
#  index_assets_on_converted_asset_id  (converted_asset_id)
#  index_assets_on_position_id         (position_id)
#
# Foreign Keys
#
#  fk_rails_...  (converted_asset_id => assets.id)
#  fk_rails_...  (position_id => positions.id)
#
require 'rails_helper'

RSpec.describe Asset, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

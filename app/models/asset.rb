# == Schema Information
#
# Table name: assets
#
#  id                 :bigint           not null, primary key
#  asset_type         :integer
#  cap_cents          :integer          default(0), not null
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
class Asset < ApplicationRecord
  belongs_to :converted_asset, class_name: "Asset", optional: true
  belongs_to :position
  has_one :company, through: :position

  has_many :marks, dependent: :destroy

  monetize :cap_cents

  enum :origination, {
    CONVERSION: 0,
    SALE: 1,
    PURCHASE: 2
  }, validate: { allow_nil: true }

  enum :asset_type, {
    SAFE: 0,
    EQUITY: 1,
    CASH: 2,
    NOTE: 3,
    ESCROW: 4
  }, validate: { allow_nil: true }
end

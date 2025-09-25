# == Schema Information
#
# Table name: marks
#
#  id             :bigint           not null, primary key
#  mark_date      :date
#  notes          :text
#  price_cents    :bigint           default(0), not null
#  price_currency :string           default("USD"), not null
#  source         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  asset_id       :bigint
#
# Indexes
#
#  index_marks_on_asset_id  (asset_id)
#
# Foreign Keys
#
#  fk_rails_...  (asset_id => assets.id)
#
class Mark < ApplicationRecord
  belongs_to :asset, optional: true

 monetize :price_cents

  enum :source, {
    PURCHASE_PRICE: 0,
    LATEST_BUYER: 1,
    OTHER: 2
  }, validate: { allow_nil: true }
end

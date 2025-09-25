# == Schema Information
#
# Table name: marks
#
#  id             :bigint           not null, primary key
#  mark_date      :date
#  notes          :text
#  price_cents    :integer          default(0), not null
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
FactoryBot.define do
  factory :mark do
    mark_date { "2025-09-25" }
    price { 1 }
    source { 1 }
    notes { "MyText" }
    asset { nil }
  end
end

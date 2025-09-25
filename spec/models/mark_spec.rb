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
require 'rails_helper'

RSpec.describe Mark, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

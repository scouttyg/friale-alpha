# == Schema Information
#
# Table name: fund_distributions
#
#  id              :bigint           not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  date            :date
#  name            :string
#  notes           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  fund_id         :bigint           not null
#  position_id     :bigint
#
# Indexes
#
#  index_fund_distributions_on_fund_id      (fund_id)
#  index_fund_distributions_on_position_id  (position_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (position_id => positions.id)
#
require 'rails_helper'

RSpec.describe FundDistribution, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

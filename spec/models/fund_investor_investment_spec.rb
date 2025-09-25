# == Schema Information
#
# Table name: fund_investor_investments
#
#  id                          :bigint           not null, primary key
#  capital_commitment_cents    :integer          default(0), not null
#  capital_commitment_currency :string           default("USD"), not null
#  capital_funded_cents        :integer          default(0), not null
#  capital_funded_currency     :string           default("USD"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  fund_id                     :bigint           not null
#  investor_account_id         :bigint
#
# Indexes
#
#  index_fund_investor_investments_on_fund_id              (fund_id)
#  index_fund_investor_investments_on_investor_account_id  (investor_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (investor_account_id => accounts.id)
#
require 'rails_helper'

RSpec.describe FundInvestorInvestment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

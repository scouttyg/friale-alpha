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
class FundInvestorInvestment < ApplicationRecord
  belongs_to :fund
  belongs_to :investor_account, class_name: "InvestorAccount", optional: true

  monetize :capital_commitment_cents
  monetize :capital_funded_cents
end

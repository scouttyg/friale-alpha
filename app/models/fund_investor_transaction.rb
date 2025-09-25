# == Schema Information
#
# Table name: fund_investor_transactions
#
#  id                          :bigint           not null, primary key
#  amount_cents                :integer          default(0), not null
#  amount_currency             :string           default("USD"), not null
#  date                        :date
#  status                      :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  bank_account_id             :bigint
#  fund_distribution_id        :bigint
#  fund_investor_investment_id :bigint           not null
#
# Indexes
#
#  idx_on_fund_investor_investment_id_1737004731             (fund_investor_investment_id)
#  index_fund_investor_transactions_on_bank_account_id       (bank_account_id)
#  index_fund_investor_transactions_on_fund_distribution_id  (fund_distribution_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => payment_methods.id)
#  fk_rails_...  (fund_distribution_id => fund_distributions.id)
#  fk_rails_...  (fund_investor_investment_id => fund_investor_investments.id)
#
class FundInvestorTransaction < ApplicationRecord
  belongs_to :bank_account, optional: true
  belongs_to :fund_distribution, optional: true
  belongs_to :fund_investor_investment

  has_one :fund, through: :fund_investor_investment
  has_one :investor, through: :fund_investor_investment

  monetize :amount_cents

  enum :status, {
    PENDING: 0,
    COMPLETE: 1
  }, validate: { allow_nil: false }


  def name
    fund_distribution&.name || "Capital call"
  end
end

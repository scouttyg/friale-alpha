# == Schema Information
#
# Table name: fund_investor_transactions
#
#  id                          :bigint           not null, primary key
#  amount_cents                :bigint           default(0), not null
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
FactoryBot.define do
  factory :fund_investor_transaction do
    date { "2025-09-25" }
    status { 1 }
    amount { 1 }
    bank_account
    fund_distribution
    fund_investor_investment
  end
end

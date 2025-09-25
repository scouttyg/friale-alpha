# == Schema Information
#
# Table name: positions
#
#  id                        :bigint           not null, primary key
#  close_date                :datetime
#  invested_capital_cents    :integer          default(0), not null
#  invested_capital_currency :string           default("USD"), not null
#  open_date                 :datetime
#  returned_capital_cents    :integer          default(0), not null
#  returned_capital_currency :string           default("USD"), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_id                :bigint           not null
#  fund_id                   :bigint           not null
#
# Indexes
#
#  index_positions_on_company_id  (company_id)
#  index_positions_on_fund_id     (fund_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (fund_id => funds.id)
#
FactoryBot.define do
  factory :position do
    invested_capital { 1 }
    returned_capital { 1 }
    open_date { "2025-09-25 11:12:37" }
    close_date { "2025-09-25 11:12:37" }
    company
    fund
  end
end

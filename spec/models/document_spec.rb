# == Schema Information
#
# Table name: documents
#
#  id                  :bigint           not null, primary key
#  date                :date
#  name                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint
#  firm_account_id     :bigint
#  fund_id             :bigint
#  investor_account_id :bigint
#
# Indexes
#
#  index_documents_on_company_id           (company_id)
#  index_documents_on_firm_account_id      (firm_account_id)
#  index_documents_on_fund_id              (fund_id)
#  index_documents_on_investor_account_id  (investor_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (firm_account_id => accounts.id)
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (investor_account_id => accounts.id)
#
require 'rails_helper'

RSpec.describe Document, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

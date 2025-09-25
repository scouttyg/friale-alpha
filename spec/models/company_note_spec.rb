# == Schema Information
#
# Table name: company_notes
#
#  id               :bigint           not null, primary key
#  active           :boolean
#  investor_visible :boolean
#  note             :text
#  performance      :integer
#  stage            :integer
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :bigint           not null
#
# Indexes
#
#  index_company_notes_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
require 'rails_helper'

RSpec.describe CompanyNote, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

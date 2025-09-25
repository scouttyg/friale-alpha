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
class CompanyNote < ApplicationRecord
  belongs_to :company

  enum :performance, {
    BELOW: 0,
    AVERAGE: 1,
    ABOVE: 2,
    HIGH: 3
  }, validate: { allow_nil: true }

  enum :stage, {
    SEED: 0,
    SERIES_A: 1,
    SERIES_B: 2,
    SERIES_C: 3,
    SERIES_D: 4,
    SERIES_E: 5,
    SERIES_F: 6,
    AQUIRED: 7
  }, validate: { allow_nil: true }
end

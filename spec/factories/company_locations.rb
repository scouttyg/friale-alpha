# == Schema Information
#
# Table name: company_locations
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :bigint           not null
#  location_id :bigint           not null
#
# Indexes
#
#  index_company_locations_on_company_id   (company_id)
#  index_company_locations_on_location_id  (location_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (location_id => locations.id)
#
FactoryBot.define do
  factory :company_location do
    company { nil }
    location { nil }
  end
end

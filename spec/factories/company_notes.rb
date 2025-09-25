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
FactoryBot.define do
  factory :company_note do
    investor_visible { false }
    note { Faker::Lorem.sentence }
    active { true }
    performance { 1 }
    stage { 1 }
    company
    url { Faker::Internet.url }
  end
end

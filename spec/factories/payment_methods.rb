# == Schema Information
#
# Table name: payment_methods
#
#  id                       :bigint           not null, primary key
#  brand                    :string
#  default                  :boolean          default(FALSE)
#  deleted_at               :datetime
#  metadata                 :jsonb
#  type                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :bigint           not null
#  stripe_payment_method_id :string           not null
#
# Indexes
#
#  index_payment_methods_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
FactoryBot.define do
  factory :payment_method do
    brand { "MyString" }
    default { false }
    deleted_at { "2025-09-18 21:32:06" }
    metadata { "" }
    type { "" }
    account { nil }
    stripe_payment_method_id { "MyString" }
  end
end

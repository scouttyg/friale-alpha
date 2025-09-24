# == Schema Information
#
# Table name: payment_methods
#
#  id                       :bigint           not null, primary key
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
#  index_payment_methods_on_account_id                (account_id)
#  index_payment_methods_on_stripe_payment_method_id  (stripe_payment_method_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
FactoryBot.define do
  factory :payment_method do
    default { false }
    deleted_at { nil }
    metadata { { last_four: "1234", brand: "visa" } }
    type { "Card" }
    association :account
    stripe_payment_method_id { "pm_#{Faker::Alphanumeric.alphanumeric(number: 14)}" }
  end
end

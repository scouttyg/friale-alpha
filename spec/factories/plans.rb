# == Schema Information
#
# Table name: plans
#
#  id                :bigint           not null, primary key
#  activated_at      :datetime
#  deactivated_at    :datetime
#  description       :text
#  name              :string
#  position          :integer
#  usage_limits      :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stripe_product_id :string
#
# Indexes
#
#  index_plans_on_stripe_product_id  (stripe_product_id) UNIQUE
#
FactoryBot.define do
  factory :plan do
    name { "#{Faker::Company.name} Plan" }
    description { Faker::Lorem.paragraph }
    activated_at { Time.zone.now }
    deactivated_at { nil }
    position { 1 }
    usage_limits { {} }
    sequence(:stripe_product_id) { |n| "prod_MOCK#{n}#{Faker::Alphanumeric.alphanumeric(number: 14)}" }
  end
end

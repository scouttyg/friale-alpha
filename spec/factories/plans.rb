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
FactoryBot.define do
  factory :plan do
    name { "#{Faker::Company.name} Plan" }
    description { Faker::Lorem.paragraph }
    activated_at { Time.zone.now }
    deactivated_at { nil }
    position { 1 }
    usage_limits { {} }
    stripe_product_id { "prod_#{Faker::Alphanumeric.alphanumeric(number: 14)}" }
  end
end

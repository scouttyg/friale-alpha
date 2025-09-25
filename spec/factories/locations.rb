# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  city       :string
#  country    :string
#  latitude   :float
#  longitude  :float
#  region     :string
#  slug       :string
#  time_zone  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :location do
    city { Faker::Address.city }
    region { Faker::Address.state }
    country { "US" }
    time_zone { "America/New_York" }
    latitude { 1.5 }
    longitude { 1.5 }
    slug { Faker::Internet.slug }
  end
end

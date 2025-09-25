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
    city { "MyString" }
    region { "MyString" }
    country { "MyString" }
    time_zone { "MyString" }
    latitude { 1.5 }
    longitude { 1.5 }
    slug { "MyString" }
  end
end

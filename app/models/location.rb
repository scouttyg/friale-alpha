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
class Location < ApplicationRecord
  has_many :company_locations, dependent: :destroy
  has_many :companies, through: :company_locations

  def full_name
    [ city, region, country ].compact.join(", ")
  end
end

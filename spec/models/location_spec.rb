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
require 'rails_helper'

RSpec.describe Location, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

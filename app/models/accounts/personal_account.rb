# == Schema Information
#
# Table name: accounts
#
#  id                 :bigint           not null, primary key
#  name               :string
#  slug               :string
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string
#
class PersonalAccount < Account
end

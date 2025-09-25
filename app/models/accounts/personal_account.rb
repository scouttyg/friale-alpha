# == Schema Information
#
# Table name: accounts
#
#  id                 :bigint           not null, primary key
#  metadata           :jsonb
#  name               :string
#  slug               :string
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string
#
# Indexes
#
#  index_accounts_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#
class PersonalAccount < Account
end

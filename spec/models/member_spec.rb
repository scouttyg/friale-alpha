# == Schema Information
#
# Table name: members
#
#  id           :bigint           not null, primary key
#  access_level :integer
#  invite_email :string
#  invite_token :string
#  source_type  :string           not null
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint
#  source_id    :bigint           not null
#  user_id      :bigint
#
# Indexes
#
#  index_members_on_creator_id  (creator_id)
#  index_members_on_source      (source_type,source_id)
#  index_members_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Member, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

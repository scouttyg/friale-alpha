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
class AccountMember < Member
  belongs_to :account, class_name: "Account", foreign_key: "source_id", inverse_of: :members

  scope :personal, -> { joins(:account).where(accounts: { type: "PersonalAccount" }) }
end

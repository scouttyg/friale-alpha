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
class Member < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :user, optional: true
  belongs_to :creator, class_name: "User", optional: true

  ACCESS_LEVELS = { guest: 10, collaborator: 20, owner: 50 }.freeze
  enum :access_level, ACCESS_LEVELS

  validates :source_type, inclusion: { in: %w[Account] }
  validates :invite_email, presence: true, unless: :user_id?
  validates :invite_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :invite_token, uniqueness: true, allow_blank: true

  before_create :generate_invite_token, if: :invite_email?
  after_create :send_invitation_email, if: :invite_email?

  scope :invited, -> { where.not(invite_email: nil) }
  scope :accepted, -> { where.not(user_id: nil) }
  scope :pending, -> { where.not(invite_email: nil).where(user_id: nil) }

  def pending?
    invite_email.present? && user_id.blank?
  end

  def accepted?
    user_id.present?
  end

  def accept!(accepting_user)
    update!(
      user: accepting_user,
      invite_email: nil,
      invite_token: nil
    )
  end

  def collaborator_or_higher?
    collaborator? || owner?
  end

  def owner?
    access_level == "owner"
  end

  def collaborator?
    access_level == "collaborator"
  end

  def guest?
    access_level == "guest"
  end

  private

  def generate_invite_token
    self.invite_token = SecureRandom.urlsafe_base64(32)
  end

  def send_invitation_email
    MemberMailer.invitation_email(self).deliver_later
  end
end

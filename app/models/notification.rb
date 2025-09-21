# == Schema Information
#
# Table name: notifications
#
#  id                :bigint           not null, primary key
#  body              :text
#  notification_type :string
#  read_at           :datetime
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_notifications_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  validates :title, presence: true
  validates :body, presence: true
  validates :notification_type, presence: true

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def mark_as_unread!
    update!(read_at: nil) if read?
  end
end

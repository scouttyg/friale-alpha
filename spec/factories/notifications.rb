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
FactoryBot.define do
  factory :notification do
    body { Faker::Lorem.paragraph }
    read_at { DateTime.parse(Faker::Time.between(from: 1.year.ago, to: DateTime.now).to_s) }
    title { Faker::Lorem.sentence }
    notification_type { 'info' }
    association :user, factory: [ :user, :confirmed, :skip_account_setup ]
  end
end

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
FactoryBot.define do
  factory :member do
    association :source, factory: :account
    association :creator, factory: :user
    access_level { 'collaborator' }
    
    trait :invited do
      invite_email { Faker::Internet.email }
      user { nil }
    end
    
    trait :accepted do
      association :user
      invite_email { nil }
      invite_token { nil }
    end
    
    trait :owner do
      access_level { 'owner' }
    end
    
    trait :guest do
      access_level { 'guest' }
    end

    factory :account_member, class: 'AccountMember' do
      association :source, factory: :account
    end
  end
end

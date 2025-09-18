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
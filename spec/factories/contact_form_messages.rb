# == Schema Information
#
# Table name: contact_form_messages
#
#  id         :bigint           not null, primary key
#  email      :string
#  message    :string
#  subject    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :contact_form_message do
    email { "MyString" }
    message { "MyString" }
    subject { "MyString" }
  end
end

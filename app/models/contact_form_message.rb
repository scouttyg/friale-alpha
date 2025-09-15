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
class ContactFormMessage < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, 'valid_email_2/email': { disposable: true, deny_list: true, message: 'domain is not permitted' }, on: :create
  validates :subject, presence: true
  validates :message, presence: true
end

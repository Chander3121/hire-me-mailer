class Setting < ApplicationRecord
  belongs_to :user

  # Simple accessors: tinymce api key, gmail_app_password, email
  # encrypt sensitive fields using Rails built-in encryption (Rails 7+)
  if respond_to?(:encrypts)
    encrypts :gmail_app_password
    encrypts :tinymce
  end

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end

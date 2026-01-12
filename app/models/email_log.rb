class EmailLog < ApplicationRecord
  belongs_to :user, optional: true
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
  validates :email, presence: true, format: { with: EMAIL_REGEX, message: "must be a valid email address" }
  validates :subject, presence: true
  validates :status, presence: true
end

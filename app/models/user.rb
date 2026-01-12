class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable, :registerable

  has_many :email_templates, dependent: :destroy
  has_many :email_logs, dependent: :destroy
  has_one :setting, dependent: :destroy

  def username
    email.split("@").first
  end
end

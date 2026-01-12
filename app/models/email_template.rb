class EmailTemplate < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, presence: true, uniqueness: { scope: :user_id }
end

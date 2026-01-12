class EmailTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end

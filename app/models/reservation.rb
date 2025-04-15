class Reservation < ApplicationRecord
  belongs_to :book
  validates :user_email, presence: true
end

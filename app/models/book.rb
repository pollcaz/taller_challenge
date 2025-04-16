class Book < ApplicationRecord
    enum status: { available: 0, reserved: 1, checked_out: 2 }

    has_many :reservations, dependent: :destroy

    validates :title, presence: true
end

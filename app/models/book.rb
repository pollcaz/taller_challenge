class Book < ApplicationRecord
    enum status: { available: 0, reserved: 1, checked_out: 2 }
end

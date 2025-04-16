require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe "validations" do
    it "is valid with a user_email and book" do
      reservation = build(:reservation)
      expect(reservation).to be_valid
    end

    it "is invalid without a user_email" do
      reservation = build(:reservation, user_email: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:user_email]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to a book" do
      book = create(:book)
      reservation = create(:reservation, book: book)
      expect(reservation.book).to eq(book)
    end
  end
end

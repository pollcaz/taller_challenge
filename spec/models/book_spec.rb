require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "validations" do
    it "is valid with a title and status" do
      book = build(:book)
      expect(book).to be_valid
    end

    it "is invalid without a title" do
      book = build(:book, title: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to include("can't be blank")
    end
  end

  describe "enums" do
    it "defines the correct statuses" do
      expect(Book.statuses.keys).to contain_exactly("available", "reserved", "checked_out")
    end

    it "stores status as a string enum" do
      book = build(:book, status: :reserved)
      expect(book.status).to eq("reserved")
    end
  end

  describe "associations" do
    it "can have multiple reservations" do
      book = create(:book)
      res1 = create(:reservation, book: book)
      res2 = create(:reservation, book: book)

      expect(book.reservations).to include(res1, res2)
      expect(book.reservations.count).to eq(2)
    end

    it "deletes associated reservations when destroyed" do
      book = create(:book)
      create(:reservation, book: book)

      expect { book.destroy }.to change { Reservation.count }.by(-1)
    end
  end
end

# spec/requests/books_spec.rb
require 'rails_helper'

RSpec.describe "Book Reservations", type: :request do
  let(:book) { create(:book) }

  describe "POST /books/:id/reserve" do
    it "reserves an available book" do
      post "/books/#{book.id}/reserve", params: { email: "test@example.com" }

      expect(response).to have_http_status(:ok)
      expect(book.reload.status).to eq("reserved")
      expect(Reservation.last.user_email).to eq("test@example.com")
    end

    it "returns error if book is already reserved" do
      book.update!(status: :reserved)
      post "/books/#{book.id}/reserve", params: { email: "test@example.com" }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns error if book is checked out" do
      book.update!(status: :checked_out)
      post "/books/#{book.id}/reserve", params: { email: "test@example.com" }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns error if email is missing" do
      post "/books/#{book.id}/reserve", params: {}

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 if book does not exist" do
      post "/books/9999/reserve", params: { email: "test@example.com" }

      expect(response).to have_http_status(:not_found)
    end
  end
end

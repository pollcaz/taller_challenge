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

  describe "GET /books" do
    before do
      Rails.cache.clear
      Book.destroy_all
    end

    let!(:books) do
      [
        create(:book, title: "A Tale of Two Cities", status: :available),
        create(:book, title: "Moby Dick", status: :available),
        create(:book, title: "Zorro", status: :available)
      ]
    end

    it "returns a successful response" do
      get "/books", params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
    end

    it "returns books in alphabetical order" do
      get "/books", params: { page: 1, per_page: 10 }

      titles = JSON.parse(response.body).map { |b| b["title"] }
      expect(titles).to eq(["A Tale of Two Cities", "Moby Dick", "Zorro"])
    end

    it "returns only selected fields (id, title, status)" do
      get "/books", params: { page: 1, per_page: 10 }

      json = JSON.parse(response.body)
      expect(json.first.keys).to match_array(["id", "title", "status"])
    end

    it "paginates the results" do
      get "/books", params: { page: 1, per_page: 2 }

      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end

    it "caches the response" do
      expect(Rails.cache.exist?("books_index_1_2")).to be false

      get "/books", params: { page: 1, per_page: 2 }
      expect(Rails.cache.exist?("books_index_1_2")).to be true

      cached_data = Rails.cache.read("books_index_1_2")
      expect(cached_data.first["title"]).to eq("A Tale of Two Cities")
    end

    it "returns an empty array if no books exist" do
      Book.delete_all
      get "/books", params: { page: 1, per_page: 10 }

      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end
end

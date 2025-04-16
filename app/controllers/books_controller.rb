class BooksController < ApplicationController
  def reserve
    book = Book.find_by(id: params[:id])
    return render_not_found unless book

    unless book.available?
      return render json: { error: "Book is not available" }, status: :bad_request
    end

    user_email = params[:email]
    return render json: { error: "Email is required" }, status: :unprocessable_entity if user_email.blank?

    book.update!(status: :reserved)

    Reservation.create!(book: book, user_email: user_email)

    render json: { message: "Book reserved successfully" }, status: :ok
  end

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    cache_key = "books_index_#{page}_#{per_page}"

    books = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      Book.select(:id, :title, :status).order(title: :asc).page(page).per(per_page).as_json
    end
  
    render json: books
  end
  

  private

  def render_not_found
    render json: { error: "Book not found" }, status: :not_found
  end
end

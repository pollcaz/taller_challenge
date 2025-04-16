class BooksController < ApplicationController
  def reserve
    result = Books::ReserveBook.new(book_id: params[:id], email: params[:email]).call
    render json: { message: "Book reserved successfully" }, status: :ok
  rescue Books::ReserveBook::Errors::NotFound
    render_not_found
  rescue Books::ReserveBook::Errors::InvalidEmail => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue Books::ReserveBook::Errors::Unavailable => e
    render json: { error: e.message }, status: :bad_request
  rescue => e
    render json: { error: "Reservation failed: #{e.message}" }, status: :internal_server_error
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

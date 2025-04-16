# app/services/books/reserve_book.rb
module Books
    class ReserveBook
      module Errors
        class Base < StandardError; end
        class NotFound < Base; end
        class InvalidEmail < Base; end
        class Unavailable < Base; end
      end

      def initialize(book_id:, email:)
        @book_id = book_id
        @user_email = email
      end

      def call
        validate_email!

        book = find_book
        validate_book!(book)

        reserve_book(book)
        build_success_response(book)
      end

      private

      attr_reader :book_id, :user_email

      def validate_email!
        raise Errors::InvalidEmail, "Email is missing" if user_email.blank?
      end

      def find_book
        Book.find_by(id: book_id)
      end

      def validate_book!(book)
        raise Errors::NotFound, "Book not found" unless book
        raise Errors::Unavailable, "Book is not available" unless book.available?
      end

      def reserve_book(book)
        ActiveRecord::Base.transaction do
          book.update!(status: :reserved)
          Reservation.create!(book: book, user_email: user_email)
        end
      end

      def build_success_response(book)
        {
          success: true,
          book_id: book.id,
          status: :reserved,
          user_email: user_email
        }
      end
    end
  end

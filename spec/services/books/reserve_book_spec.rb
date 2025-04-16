# spec/services/books/reserve_book_spec.rb
require 'rails_helper'

RSpec.describe Books::ReserveBook do
  describe '#call' do
    let(:service) { described_class.new(book_id: book.id, email: user_email) }
    let(:user_email) { 'user@example.com' }
    let(:book) { create(:book, status: :available) }

    context 'when everything is valid' do
      it 'reserves the book successfully' do
        expect { service.call }.to change { book.reload.status }.to('reserved')
      end

      it 'creates a reservation' do
        expect { service.call }.to change(Reservation, :count).by(1)
      end

      it 'returns a success response' do
        result = service.call
        expect(result).to eq({
          success: true,
          book_id: book.id,
          status: :reserved,
          user_email: user_email
        })
      end
    end

    context 'when email is invalid' do
      let(:user_email) { '' }

      it 'raises an InvalidEmail error' do
        expect { service.call }.to raise_error(
          Books::ReserveBook::Errors::InvalidEmail,
          'Email is missing'
        )
      end

      it 'does not change the book status' do
        expect {
          begin; service.call; rescue; end
        }.not_to change { book.reload.status }
      end

      it 'does not create a reservation' do
        expect {
          begin; service.call; rescue; end
        }.not_to change(Reservation, :count)
      end
    end

    context 'when book is not found' do
      let(:service) { described_class.new(book_id: 9999, email: user_email) }

      it 'raises a NotFound error' do
        expect { service.call }.to raise_error(
          Books::ReserveBook::Errors::NotFound,
          'Book not found'
        )
      end
    end

    context 'when book is not available' do
      let(:book) { create(:book, status: :reserved) }

      it 'raises an Unavailable error' do
        expect { service.call }.to raise_error(
          Books::ReserveBook::Errors::Unavailable,
          'Book is not available'
        )
      end

      it 'does not create a reservation' do
        expect {
          begin; service.call; rescue; end
        }.not_to change(Reservation, :count)
      end
    end

    context 'when reservation fails' do
      before do
        allow(Reservation).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'does not change the book status' do
        expect {
          begin; service.call; rescue; end
        }.not_to change { book.reload.status }
      end

      it 'raises the original error' do
        expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end

# spec/controllers/books_controller_spec.rb
require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  describe 'POST #reserve' do
    let(:book) { create(:book) }
    let(:valid_params) { { id: book.id, email: 'user@example.com' } }

    context 'with valid parameters' do
      it 'returns success response' do
        post :reserve, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Book reserved successfully')
      end

      it 'calls the ReserveBook service' do
        reserve_service = instance_double(Books::ReserveBook, call: { success: true })
        allow(Books::ReserveBook).to receive(:new).and_return(reserve_service)

        post :reserve, params: valid_params

        expect(Books::ReserveBook).to have_received(:new).with(
          book_id: book.id.to_s,
          email: 'user@example.com'
        )
        expect(reserve_service).to have_received(:call)
      end
    end

    context 'when book is not found' do
      it 'returns not found status' do
        post :reserve, params: { id: 9999, email: 'user@example.com' }
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('Book not found')
      end
    end

    context 'when email is missing' do
      it 'returns unprocessable entity status' do
        post :reserve, params: { id: book.id, email: '' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Email is missing')
      end
    end

    context 'when book is not available' do
      let(:book) { create(:book, status: :reserved) }

      it 'returns bad request status' do
        post :reserve, params: valid_params
        expect(response).to have_http_status(:bad_request)
        expect(json_response['error']).to eq('Book is not available')
      end
    end

    context 'when reservation fails' do
      before do
        allow_any_instance_of(Books::ReserveBook).to receive(:call).and_raise(StandardError, 'Unexpected error')
      end

      it 'returns internal server error' do
        post :reserve, params: valid_params
        expect(response).to have_http_status(:internal_server_error)
        expect(json_response['error']).to eq('Reservation failed: Unexpected error')
      end
    end
  end

  describe 'GET #index' do
    let!(:books) { create_list(:book, 15) }

    context 'without pagination parameters' do
      it 'returns first page with 10 books' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(10)
      end
    end

    context 'with pagination parameters' do
      it 'returns requested page size' do
        get :index, params: { per_page: 5, page: 2 }
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(5)
      end
    end

    it 'uses cache' do
      expect(Rails.cache).to receive(:fetch).with('books_index_1_10', expires_in: 30.minutes)
      get :index
    end

    it 'returns books ordered by title' do
      get :index
      titles = json_response.map { |b| b['title'] }
      expect(titles).to eq(titles.sort)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
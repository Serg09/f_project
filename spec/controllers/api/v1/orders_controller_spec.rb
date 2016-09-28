require 'rails_helper'

describe Api::V1::OrdersController do
  let!(:order) { FactoryGirl.create :order }

  context 'when a valid auth token is present' do
    before { request.headers['Authorization'] = 'Token token=abc123' }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end

      it 'returns the list of orders' do
        get :index
        result = JSON.parse(response.body).map{|o| o['id']}
        expect(result).to eq [order.id]
      end
    end
  end

  context 'when no valid auth token is present' do
    describe 'get :index' do
      it 'returns status "unauthorized"' do
        get :index
        expect(response).to have_http_status :unauthorized
      end

      it 'does not return any orders' do
        get :index
        expect(response.body).not_to match(Regexp.new(order.customer_name))
      end

      it 'returns an error message' do
        get :index
        result = JSON.parse(response.body, symbolize_names: true)
        expect(result).to eq({error: 'Bad credentials'})
      end
    end
  end
end

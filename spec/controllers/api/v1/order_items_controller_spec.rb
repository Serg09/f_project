require 'rails_helper'

describe Api::V1::OrderItemsController, type: :controller do
  let (:client) { FactoryGirl.create(:client) }
  let (:order) { FactoryGirl.create(:order, client: client) }
  let!(:item) { FactoryGirl.create(:order_item, order: order) }

  context 'when an auth token is present' do
    before do
      request.headers['Authorization'] = "Token token=#{client.auth_token}"
    end

    context 'and the order belongs to the client' do
      describe 'get :index' do
        it 'is successful' do
          get :index, order_id: order
          expect(response).to have_http_status :success
        end

        it 'returns a list of items in the order' do
          get :index, order_id: order
          result = JSON.parse(response.body, symbolize_names: true)
          skus = result.map{|i| i[:sku]}
          expect(skus).to eq [item.sku]
        end
      end
    end

    context 'and the order does not belong to the client' do
      let (:other_client) { FactoryGirl.create(:client) }
      before do
        request.headers['Authorization'] = "Token token=#{other_client.auth_token}"
      end

      describe 'get :index' do
        it 'returns http status "not found"' do
          get :index, order_id: order
          expect(response).to have_http_status :not_found
        end

        it 'does not return an order items' do
          get :index, order_id: order
          expect(response.body).not_to match /sku/
        end
      end
    end
  end

  context 'when an auth token is absent' do
    describe 'get :index' do
      it 'returns http status "unauthorized"' do
        get :index, order_id: order
        expect(response).to have_http_status :unauthorized
      end

      it 'does not return an order items' do
        get :index, order_id: order
        expect(response.body).not_to match /sku/
      end
    end
  end
end

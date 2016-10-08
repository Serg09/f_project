require 'rails_helper'

describe Api::V1::OrderItemsController, type: :controller do
  let (:client) { FactoryGirl.create(:client) }
  let (:order) { FactoryGirl.create(:order, client: client) }
  let!(:item) { FactoryGirl.create(:order_item, order: order) }
  let (:product) { FactoryGirl.create(:product, price: 9.99) }
  let (:attributes) do
    {
      sku: product.sku,
      quantity: 3
    }
  end

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

      describe 'post :create' do
        it 'is successful' do
          post :create, order_id: order, item: attributes
          expect(response).to have_http_status :success
        end

        it 'creates an order item record' do
          expect do
            post :create, order_id: order, item: attributes
          end.to change(order.items, :count).by(1)
        end

        it 'returns the new item' do
          post :create, order_id: order, item: attributes
          result = JSON.parse(response.body, symbolize_names: true)
          expect(result).to include({
            sku: product.sku,
            quantity: 3,
            unit_price: 9.99,
            extended_price: 29.97
          })
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

      describe 'post :create' do
        it 'returns http status "not found"' do
          post :create, order_id: order, item: attributes
          expect(response).to have_http_status :not_found
        end

        it 'does not create an order item record' do
          expect do
            post :create, order_id: order, item: attributes
          end.not_to change(OrderItem, :count)
        end

        it 'does not return the new item' do
          post :create, order_id: order, item: attributes
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

    describe 'post :create' do
      it 'returns http status "unauthorized"' do
        post :create, order_id: order, item: attributes
        expect(response).to have_http_status :unauthorized
      end

      it 'does not create an order item record' do
        expect do
          post :create, order_id: order, item: attributes
        end.not_to change(OrderItem, :count)
      end

      it 'does not return the new item' do
        post :create, order_id: order, item: attributes
        expect(response.body).not_to match /sku/
      end
    end
  end
end

require 'rails_helper'

describe Api::V1::ProductsController do
  let (:client) { FactoryGirl.create(:client) }
  let!(:product1) { FactoryGirl.create(:product) }
  let!(:product2) { FactoryGirl.create(:product) }

  context 'when an authentication token is present' do
    let (:auth_token) { client.auth_token }
    before { request.headers['Authorization'] = "Token token=#{auth_token}" }

    describe '#current_client' do
      it 'is a reference to the associated client' do
        get :index
        expect(controller.current_client).to eq client
      end
    end

    describe 'get :index' do
      it 'is successfull' do
        get :index
        expect(response).to have_http_status :success
      end

      it 'returns the list of products' do
        get :index
        result = JSON.parse(response.body).map{|p| p['id']}
        expect(result).to include product1.id, product2.id
      end
    end

    describe 'get :show' do
      context 'given a SKU' do
        it 'is successful' do
          get :show, sku: product1.sku
          expect(response).to have_http_status :success
        end

        it 'returns the specified product' do
          get :show, sku: product1.sku
          actual = JSON.parse(response.body).
            select_keys('id', 'sku', 'description', 'price')
          actual['price'] = BigDecimal.new(actual['price'], 4)

          expected = product1.as_json(only: [:id, :sku, :description, :price])

          expect(actual).to eq expected
        end
      end
    end
  end

  context 'when an authentication token is absent' do
    describe '#current_client' do
      it 'is nil' do
        get :index
        expect(controller.current_client).to be_nil
      end
    end

    describe 'get :index' do
      it 'returns status "unauthorized"' do
        get :index
        expect(response).to have_http_status :unauthorized
      end

      it 'does not return a list of products' do
        get :index
        expect(response.body).not_to match(Regexp.new(product1.sku))
      end
    end

    describe 'get :show' do
      context 'given a sku' do
        it 'returns tatus "unauthoried"' do
          get :show, sku: product1.sku
          expect(response).to have_http_status :unauthorized
        end

        it 'does not return the product' do
          get :show, sku: product1.sku
          expect(response.body).not_to match(Regexp.new(product1.sku))
        end
      end
    end
  end
end

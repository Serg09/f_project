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
  end
end

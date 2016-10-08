require 'rails_helper'

describe Api::V1::OrdersController do
  let (:client) { FactoryGirl.create :client }
  let!(:order) { FactoryGirl.create :order, client: client }
  let!(:other_order) { FactoryGirl.create :order }
  let (:attributes) do
    {
      customer_name: 'John Doe',
      telephone: '2145551212',
      customer_email: 'john@doe.com',
      shipping_address_attributes: {
        line_1: '1234 Main St',
        line_2: 'Apt 227',
        city: 'Dallas',
        state: 'TX',
        postal_code: '75200',
        country_code: 'US'
      }
    }
  end

  context 'when a valid auth token is present' do
    let (:auth_token) { client.auth_token }
    before { request.headers['Authorization'] = "Token token=#{auth_token}" }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end

      it 'returns the list of orders belonging to the client' do
        get :index
        result = JSON.parse(response.body).map{|o| o['id']}
        expect(result).to include order.id
      end

      it 'excludes orders that do not belong to the client' do
        get :index
        result = JSON.parse(response.body).map{|o| o['id']}
        expect(result).not_to include other_order.id
      end
    end

    describe 'post :create' do
      it 'is successful' do
        post :create, order: attributes
        expect(response).to have_http_status :success
      end

      it 'creates an order record' do
        expect do
          post :create, order: attributes
        end.to change(Order, :count).by(1)
      end

      it 'returns the order' do
        post :create, order: attributes
        result = JSON.parse(response.body, symbolize_names: true)
        expect(result). to eq({
          customer_name: 'John Doe',
          telephone: '2145551212',
          order_date: '2016-03-02',
          status: 'incipient',
          client_id: client.id,
          customer_email: 'john@.doe.com'
        })
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

    describe 'post :create' do
      it 'is returns status code "unauthorized"'
      it 'does not create an order record'
      it 'does not return an order'
    end
  end
end

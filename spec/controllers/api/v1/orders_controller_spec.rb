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
        recipient: 'John Doe',
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
        expect(json_response.map{|o| o[:id]}).to include order.id
      end

      it 'excludes orders that do not belong to the client' do
        get :index
        expect(json_response).not_to include other_order.id
      end
    end

    describe 'get :show' do
      context 'for an order belonging to the client' do
        it 'is successful' do
          get :show, id: order
          expect(response).to have_http_status :success
        end

        it 'returns the order' do
          get :show, id: order
          expect(json_response).to include id: order.id
        end
      end

      context 'for an order not belonging to the client' do
        let (:other_order) { FactoryGirl.create(:order) }

        it 'returns http status "not found"' do
          get :show, id: other_order
          expect(response).to have_http_status :not_found
        end

        it 'does not return the order' do
          get :show, id: other_order
          expect(json_response).not_to include id: other_order.id
        end
      end
    end

    describe 'post :create' do
      context 'with full order details' do
        it 'is successful' do
          post :create, order: attributes
          expect(response).to have_http_status :success
        end

        it 'creates an order record' do
          expect do
            post :create, order: attributes
          end.to change(Order, :count).by(1)
        end

        it 'creates an address record' do
          expect do
            post :create, order: attributes
          end.to change(Address, :count).by(1)
        end

        it 'returns the order' do
          Timecop.freeze(DateTime.parse('2016-03-02 12:00:00')) do
            post :create, order: attributes
          end
          expect(json_response).to include({
            customer_name: 'John Doe',
            telephone: '2145551212',
            order_date: '2016-03-02',
            status: 'incipient',
            client_id: client.id,
            customer_email: 'john@doe.com',
            batch_id: nil,
            client_order_id: nil,
            error: nil
          })
        end
      end

      context 'with minimum order details' do
        let (:attributes) { {} }

        it 'is successful' do
          post :create, order: attributes
          expect(response).to have_http_status :success
        end

        it 'creates an order record' do
          expect do
            post :create, order: attributes
          end.to change(Order, :count).by(1)
        end

        it 'does not create an address record' do
          expect do
            post :create, order: attributes
          end.not_to change(Address, :count)
        end

        it 'returns the order' do
          Timecop.freeze(DateTime.parse('2016-03-02 12:00:00')) do
            post :create, order: attributes
          end
          expect(json_response).to include({
            order_date: '2016-03-02',
            status: 'incipient',
            client_id: client.id,
            batch_id: nil,
            client_order_id: nil,
            error: nil
          })
        end
      end
    end

    # TODO Share this with the non-api controller spec?
    context 'with an incipient order' do
      context 'that belongs to the client' do
        describe 'patch :submit' do
          it 'is successful'
          it 'returns the order'
          it 'changes the order status to "submitted"'
        end
      end

      context 'that does not belong to the client' do
        describe 'patch :submit' do
          it 'returns "not found"'
          it 'does not return the order'
          it 'does not change the order status'
        end
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
        expect(json_response).to eq({error: 'Bad credentials'})
      end
    end

    describe 'post :create' do
      it 'is returns status code "unauthorized"' do
        post :create, order: attributes
        expect(response).to have_http_status :unauthorized
      end

      it 'does not create an order record' do
        expect do
          post :create, order: attributes
        end.not_to change(Order, :count)
      end

      it 'does not return an order' do
        post :create, order: attributes
        expect(response.body).not_to match /customer_name/
      end
    end
  end
end

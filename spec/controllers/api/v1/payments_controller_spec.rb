require 'rails_helper'

describe Api::V1::PaymentsController do
  let (:client) { FactoryGirl.create :client }
  let (:payment_token) { SecureRandom.base64(512) }
  let (:order) { FactoryGirl.create(:order, client: client, item_count: 0) }
  let (:product) { FactoryGirl.create(:product, price: 100) }
  let!(:order_item) do
    FactoryGirl.create(:order_item, order: order,
                                    sku: product.sku,
                                    unit_price: 100,
                                    tax: 0,
                                    quantity: 1)
  end
  let (:attributes) do
    {
      nonce: Faker::Number.hexadecimal(40)
    }
  end

  before do
    allow(Braintree::ClientToken).to \
      receive(:generate).
      and_return(payment_token)
  end

  context 'when an authorization token is present' do
    let (:auth_token) { client.auth_token }
    before { request.headers['Authorization'] = "Token token=#{auth_token}" }

    describe 'get :token' do
      it 'is successful' do
        get :token
        expect(response).to have_http_status :success
      end

      it 'returns an authorization token' do
        get :token
        result = JSON.parse(response.body, symbolize_names: true)
        expect(result[:token]).to eq payment_token
      end
    end

    describe 'post :create' do
      context 'on provider success' do
        before do
          expect(Braintree::Transaction).to \
            receive(:sale).
            and_return(payment_provider_response('approved'))
        end

        it 'is successful' do
          post :create, order_id: order, payment: attributes
          expect(response).to have_http_status :success
        end

        it 'creates a payment record' do
          expect do
            post :create, order_id: order, payment: attributes
          end.to change(order.payments, :count).by(1)
        end

        it 'returns payment information' do
          post :create, order_id: order, payment: attributes
          result = JSON.parse(response.body, symbolize_names: true)
          expect(result).to include state: 'approved',
                                    amount: 105 # includes shipping, added automatically
        end
      end

      context 'on provider failure' do
        before do
          expect(Braintree::Transaction).to \
            receive(:sale).
            and_return(payment_provider_response('denied'))
        end

        it 'returns http status "unprocessable entity"' do
          post :create, order_id: order, payment: attributes
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'creates a payment record' do
          expect do
            post :create, order_id: order, payment: attributes
          end.to change(order.payments, :count).by(1)
        end

        it 'returns an error message' do
          post :create, order_id: order, payment: attributes
          result = JSON.parse(response.body, symbolize_names: true)
          expect(result).to include message: "The payment was not approved by the provider."
        end

        it 'does not return payment information' do
          post :create, order_id: order, payment: attributes
          expect(response.body).not_to match /amount/
        end
      end

      context 'if the order does not belong to the client' do
        let (:other_order) { FactoryGirl.create(:order) }

        it 'does not contact the payment provider' do
          expect(Braintree::Transaction).not_to \
            receive(:sale)
          post :create, order_id: other_order, payment: attributes
        end

        it 'returns http status "not found"' do
          post :create, order_id: other_order, payment: attributes
          expect(response).to have_http_status :not_found
        end

        it 'does not create the payment' do
          expect do
            post :create, order_id: other_order, payment: attributes
          end.not_to change(Payment, :count)
        end

        it 'does not retutn payment information' do
          post :create, order_id: other_order, payment: attributes
          expect(response.body).not_to match /amount/
        end

        it 'returns an error message' do
          post :create, order_id: other_order, payment: attributes
          result = JSON.parse(response.body, symbolize_names: true)
          expect(result).to include message: "not found"
        end
      end
    end
  end

  context 'when an authorization token is absent' do
    describe 'get :token' do
      it 'returns status code "unauthorized"' do
        get :token
        expect(response).to have_http_status :unauthorized
      end

      it 'does not return a token' do
        get :token
        expect(response.body).not_to match /[a-z0-9]{128,}={0,2}/i
      end
    end

    describe 'post :create' do
      it 'returns status code "unauthorized"' do
        post :create, order_id: order, payment: attributes
        expect(response).to have_http_status :unauthorized
      end

      it 'does not contact the payment provider' do
        expect(Braintree::Transaction).not_to \
          receive(:sale)
        post :create, order_id: order, payment: attributes
      end

      it 'does not create a payment' do
        expect do
          post :create, order_id: order, payment: attributes
        end.not_to change(Payment, :count)
      end

      it 'does not return payment information' do
        post :create, order_id: order, payment: attributes
        result = JSON.parse(response.body, symbolize_names: true)
        expect(result).not_to match /amount/
      end
    end
  end
end

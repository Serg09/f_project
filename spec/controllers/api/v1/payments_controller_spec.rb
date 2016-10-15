require 'rails_helper'

describe Api::V1::PaymentsController do
  let (:client) { FactoryGirl.create :client }
  let (:payment_token) { SecureRandom.base64(512) }
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
  end
end

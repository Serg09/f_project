require 'rails_helper'

describe Api::V1::ShipMethodsController, type: :controller do
  let (:client) { FactoryGirl.create :client }
  let!(:ship_method_1) { FactoryGirl.create :ship_method }
  let!(:ship_method_2) { FactoryGirl.create :ship_method }

  context 'with a valid auth token' do
    let (:auth_token) { client.auth_token }
    before { request.headers['Authorization'] = "Token token=#{auth_token}" }

    describe 'GET :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end

      it 'returns the available ship methods' do
        get :index
        expect(json_response.map{|m| m[:id]}).to \
          contain_exactly ship_method_1.id, ship_method_2.id
      end

      it 'excludes the calculator class' do
        get :index
        expect(json_response.map{|m| m[:calculator_class]}.compact).to \
          be_empty
      end
    end
  end

  context 'without a valid auth token' do
    describe 'GET :index' do
      it 'is returns "access denied"' do
        get :index
        expect(response).to have_http_status :unauthorized
      end

      it 'does not return any ship method data' do
        get :index
        expect(json_response.except(:error)).to be_empty
      end
    end
  end
end

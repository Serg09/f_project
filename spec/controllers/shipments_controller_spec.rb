require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  let (:order) { FactoryGirl.create :order }
  let (:attributes) do
    {
      ship_date: '3/2/2017',
      external_id: SecureRandom.hex(16),
      weight: 1.2,
      freight_charge: 2.75,
      handling_charge: 1.65,
      quantity: 1
    }
  end

  context 'for an authenticated user' do
    let (:user) { FactoryGirl.create :user }
    before { sign_in user}

    describe "GET #index" do
      it "returns http success" do
        get :index, order_id: order
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #new' do
      it 'is successful' do
        get :new, order_id: order
        expect(response).to have_http_status :success
      end
    end

    describe 'POST #create' do
      it 'redirects to the shipment item index page' do
        post :create, order_id: order, shipment: attributes
        expect(response).to redirect_to shipment_shipment_items_path(Shipment.last)
      end

      it 'creates a shipment record' do
        expect do
          post :create, order_id: order, shipment: attributes
        end.to change(order.shipments, :count).by(1)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #index" do
      it "redirects to the sign in page" do
        get :index, order_id: order
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'GET #new' do
      it "redirects to the sign in page" do
        get :new, order_id: order
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'POST #create' do
      it "redirects to the sign in page" do
        post :create, order_id: order, shipment: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create a shipment record' do
        expect do
          post :create, order_id: order, shipment: attributes
        end.not_to change(Shipment, :count)
      end
    end
  end
end

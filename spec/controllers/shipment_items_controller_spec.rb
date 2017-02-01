require 'rails_helper'

RSpec.describe ShipmentItemsController, type: :controller do
  let (:shipment) { FactoryGirl.create :shipment }

  context 'for an authenticated user' do
    let (:user) { FactoryGirl.create :user }
    before { sign_in user }

    describe "GET #index" do
      it "returns http success" do
        get :index, shipment_id: shipment
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #new" do
      it "returns http success" do
        get :new, shipment_id: shipment
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #index" do
      it 'redirects to the sign in page' do
        get :index, shipment_id: shipment
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #new" do
      it 'redirects to the sign in page' do
        get :new, shipment_id: shipment
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end

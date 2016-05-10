require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let (:user) { FactoryGirl.create(:user) }
  let (:order) { FactoryGirl.create(:order) }

  context 'for an authenticated user' do
    before(:each) { sign_in user }

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #show" do
      it "returns http success" do
        get :show, id: order
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #index" do
      it "redirects to the sign in page" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #show" do
      it "redirects to the sign in page" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end

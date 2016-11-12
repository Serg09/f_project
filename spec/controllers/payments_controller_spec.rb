require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let (:user) { FactoryGirl.create :user }
  let (:payment) { FactoryGirl.create :payment }

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
        get :show, id: payment
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'GET #index' do
      it 'redirects to the sign in page' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'GET #show' do
      it 'redirects to the sign in page' do
        get :show, id: payment
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end

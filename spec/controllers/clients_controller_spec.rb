require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  let (:client) { FactoryGirl.create(:client) }
  let (:attributes) do
    {
      name: 'ACME Publishing',
      abbreviation: 'AP'
    }
  end

  context 'for an authenticated user' do
    let (:user) { FactoryGirl.create(:user) }
    before(:each) { sign_in user}

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #show" do
      it "returns http success" do
        get :show, id: client
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #create' do
      it 'redirects to the client index page' do
        post :create, client: attributes
        expect(response).to redirect_to clients_path
      end

      it 'creates a client record' do
        expect do
          post :create, client: attributes
        end.to change(Client, :count).by(1)
      end
    end

    describe "GET #edit" do
      it "returns http success" do
        get :edit, id: client
        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'redirects to the client index page' do
        patch :update, id: client, client: attributes
        expect(response).to redirect_to clients_path
      end

      it 'updates the specified client' do
        expect do
          patch :update, id: client, client: attributes
          client.reload
        end.to change(client, :name).to('ACME Publishing')
      end
    end

    describe 'DELETE #destroy' do
      let!(:client) { FactoryGirl.create(:client) }

      it 'redirects to the client index page' do
        delete :destroy, id: client
        expect(response).to redirect_to clients_path
      end

      it 'removes the client record' do
        expect do
          delete :destroy, id: client
        end.to change(Client, :count).by(-1)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #index" do
      it 'redirects to the sign in page' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #show" do
      it 'redirects to the sign in page' do
        get :show, id: client
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #new" do
      it 'redirects to the sign in page' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'POST #create' do
      it 'redirects to the sign in page' do
        post :create, client: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create a client record' do
        expect do
          post :create, client: attributes
        end.not_to change(Client, :count)
      end
    end

    describe "GET #edit" do
      it 'redirects to the sign in page' do
        get :edit, id: client
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'PATCH #update' do
      it 'redirects to the sign in page' do
        patch :update, id: client, client: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not update the specified client' do
        expect do
          patch :update, id: client, client: attributes
          client.reload
        end.not_to change(client, :name)
      end
    end

    describe 'DELETE #destroy' do
      let!(:client) { FactoryGirl.create(:client) }

      it 'redirects to the sign in page' do
        delete :destroy, id: client
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not remote the client record' do
        expect do
          delete :destroy, id: client
        end.not_to change(Client, :count)
      end
    end
  end
end

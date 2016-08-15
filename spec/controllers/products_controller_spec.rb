require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let (:product) { FactoryGirl.create(:product) }
  let (:attributes) do
    {
      sku: '123456',
      description: 'Deluxe Widget',
      price: '24.99'
    }
  end

  context 'for an authenticated user' do
    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #show" do
      it "returns http success" do
        get :show
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
      it 'creates a product record' do
        expect do
          post :create, product: attributes
        end.to change(Product, :count).by(1)
      end

      it 'redirects to the product index page' do
        post :create, product: attributes
        expect(response).to redirect_to(products_path)
      end
    end

    describe "GET #edit" do
      it "returns http success" do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'updates the specified product' do
        expect do
          patch :update, id: product, product: attributes
          product.reload
        end.to change(product, description).to(product[:description])
      end

      it 'redirects to the product index page' do
        patch :update, id: product, product: attributes
        expect(response).to redirect_to products_path
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #index" do
      it "redirects to the sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET #show" do
      it "redirects to the sign in page" do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET #new" do
      it "redirects to the sign in page" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST #create' do
      it 'does not create a product record' do
        expect do
          post :create, product: attributes
        end.not_to change(Product, :count)
      end

      it "redirects to the sign in page" do
        post :create, product: attributes
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET #edit" do
      it "redirects to the sign in page" do
        get :edit
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'PATCH #update' do
      it 'does not update the specified product' do
        expect do
          patch :update, id: product, product: attributes
          product.reload
        end.not_to change(product, :description)
      end

      it "redirects to the sign in page" do
        patch :update, id: product, product: attributes
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

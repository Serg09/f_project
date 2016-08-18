require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let (:user) { FactoryGirl.create(:user) }
  let (:client) { FactoryGirl.create(:client) }
  let (:order) { FactoryGirl.create(:order) }

  let (:attributes) do
    {
      order_date: '3/2/2016',
      customer_name: 'Sally Readerton',
      client_id: client.id
    }
  end

  let (:shipping_address_attributes) do
    {
      recipient: 'Sally Readerton',
      address_1: '1234 Main St',
      address_2: 'Apt 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75200',
      country_code: 'US'
    }
  end

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

    describe 'GET #new' do
      it 'is successfull' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #create' do
      it 'redirects to the order index page' do
        post :create, order: attributes, shipping_address: shipping_address_attributes
        expect(response).to redirect_to orders_path
      end

      it 'creates an order record' do
        expect do
          post :create, order: attributes, shipping_address: shipping_address_attributes
        end.to change(Order, :count).by(1)
      end

      it 'creates add address record' do
        expect do
          post :create, order: attributes, shipping_address: shipping_address_attributes
        end.to change(Address, :count).by(1)
      end

      it 'links the new address record to the new order record' #do
      #  post :create, order: attributes, shipping_address: shipping_address_attributes
      #  expect(Order.last..shipping_address_id).to eq(Address.last.id)
      #end
    end

    context 'for a new order' do
      let!(:order) { FactoryGirl.create(:new_order) }

      describe 'GET #edit' do
        it 'is successfull' do
          get :edit, id: order
          expect(response).to have_http_status(:success)
        end
      end

      describe 'PATCH #update' do
        it 'redirects to the order index page' do
          patch :update, id: order, order: attributes, shipping_address: shipping_address_attributes
          expect(response).to redirect_to orders_path
        end

        it 'updates the order' do
          expect do
            patch :update, id: order, order: attributes, shipping_address: shipping_address_attributes
            order.reload
          end.to change(order, :order_date).to Date.parse('2016-03-02')
        end
      end

      describe 'DELETE #destroy' do
        it 'redirects to the order index page' do
          delete :destroy, id: order
          expect(response).to redirect_to orders_path
        end

        it 'removes the order record' do
          expect do
            delete :destroy, id: order
          end.to change(Order, :count).by(-1)
        end
      end
    end

    shared_examples_for 'an immutable order' do
      describe 'GET #edit' do
        it 'redirects to the order show page' do
          get :edit, id: order
          expect(response).to redirect_to(order_path(order))
        end
      end

      describe 'PATCH #update' do
        it 'redirects to the order show page' do
          patch :update, id: order, order: attributes, shipping_address: shipping_address_attributes
          expect(response).to redirect_to(order_path(order))
        end

        it 'does not update the order' do
          expect do
            patch :update, id: order, order: attributes, shipping_address: shipping_address_attributes
            order.reload
          end.not_to change(order, :order_date)
        end

        it 'renders an error message' do
          patch :update, id: order, order: attributes, shipping_address: shipping_address_attributes
          expect(flash[:alert]).to eq 'This order cannot be edited.'
        end
      end

      describe 'DELETE #destroy' do
        it 'redirects to the order show page' do
          delete :destroy, id: order
          expect(response).to redirect_to order_path(order)
        end

        it 'does not remove the order record' do
          expect do
            delete :destroy, id: order
          end.not_to change(Order, :count)
        end

        it 'renders an error message' do
          delete :destroy, id: order
          expect(flash[:alert]).to eq 'This order cannot be removed.'
        end
      end
    end

    context 'for an exported order' do
      it_behaves_like 'an immutable order' do
        let!(:order) { FactoryGirl.create(:exported_order) }
      end
    end

    context 'for a processing order' do
      it_behaves_like 'an immutable order' do
        let!(:order) { FactoryGirl.create(:processing_order) }
      end
    end

    context 'for a shipped order' do
      it_behaves_like 'an immutable order' do
        let!(:order) { FactoryGirl.create(:shipped_order) }
      end
    end

    context 'for a rejected order' do
      # TODO Should create a new order or be able to modify a rejected order?
      it_behaves_like 'an immutable order' do
        let!(:order) { FactoryGirl.create(:rejected_order) }
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

    describe 'GET #new' do
      it "redirects to the sign in page" do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'POST #create' do
      it "redirects to the sign in page" do
        post :create, order: attributes, shipping_address: shipping_address_attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create an order record' do
        expect do
          post :create, order: attributes, shipping_address: shipping_address_attributes
        end.not_to change(Order, :count)
      end
    end

    describe 'GET #edit' do
      it "redirects to the sign in page" do
        get :edit, id: order
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'PATCH #update' do
      it "redirects to the sign in page" do
        patch :update, id: order, order: attributes, shipping_address: shipping_address_attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not update the order' do
        expect do
          patch :update, id: order, order: attributes, shipping_address: shipping_address_attributes
          order.reload
        end.not_to change(order, :order_date)
      end
    end

    describe 'DELETE #destroy' do
      let!(:order) { FactoryGirl.create(:new_order) }

      it "redirects to the sign in page" do
        delete :destroy, id: order
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not remove the order record' do
        expect do
          delete :destroy, id: order
        end.not_to change(Order, :count)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe OrderItemsController, type: :controller do
  let (:product) { FactoryGirl.create(:product) }
  let (:order) { FactoryGirl.create(:incipient_order, ship_method: nil) }
  let (:order_item) { FactoryGirl.create(:order_item, order: order,
                                                      quantity: 1) }
  let (:attributes) do
    {
      sku: product.sku,
      quantity: 2
    }
  end

  context 'for an authenticated user' do
    let (:user) { FactoryGirl.create(:user) }
    before(:each) { sign_in user }

    context 'for an incipient order' do
      describe "GET #new" do
        it "returns http success" do
          get :new, order_id: order
          expect(response).to have_http_status(:success)
        end
      end

      describe 'POST #create' do
        it 'redirects to the order edit page' do
          post :create, order_id: order, order_item: attributes
          expect(response).to redirect_to edit_order_path(order)
        end

        it 'creates an order item record' do
          expect do
            post :create, order_id: order, order_item: attributes
          end.to change(order.items, :count).by(1)
        end
      end

      describe "GET #edit" do
        it "returns http success" do
          get :edit, id: order_item
          expect(response).to have_http_status(:success)
        end
      end

      describe 'PATCH #update' do
        it 'redirects to the order edit page' do
          patch :update, id: order_item, order_item: attributes
          expect(response).to redirect_to edit_order_path(order)
        end

        it 'updates the order item record' do
          expect do
            patch :update, id: order_item, order_item: attributes
            order_item.reload
          end.to change(order_item, :quantity).to 2
        end
      end

      describe 'DELETE #destroy' do
        let!(:order_item) { FactoryGirl.create(:order_item, order: order) }

        it 'redirects to the order edit page' do
          delete :destroy, id: order_item
          expect(response).to redirect_to edit_order_path(order)
        end

        it 'removes the order item record' do
          expect do
            delete :destroy, id: order_item
          end.to change(order.items, :count).by(-1)
        end
      end
    end

    shared_examples 'an immutable order' do
      describe "GET #new" do
        it 'redirects to the order show page' do
          get :new, order_id: order
          expect(response).to redirect_to order_path(order)
        end
      end

      describe 'POST #create' do
        it 'redirects to the order show page' do
          post :create, order_id: order, order_item: attributes
          expect(response).to redirect_to order_path(order)
        end

        it 'does not create an order item record' do
          expect do
            post :create, order_id: order, order_item: attributes
          end.not_to change(OrderItem, :count)
        end
      end

      describe "GET #edit" do
        it 'redirects to the order show page' do
          get :edit, id: order_item
          expect(response).to redirect_to order_path(order)
        end
      end

      describe 'PATCH #update' do
        it 'redirects to the order show page' do
          patch :update, id: order_item, order_item: attributes
          expect(response).to redirect_to order_path(order)
        end

        it 'does not update the order item record' do
          expect do
            patch :update, id: order_item, order_item: attributes
            order_item.reload
          end.not_to change(order_item, :quantity)
        end
      end

      describe 'DELETE #destroy' do
        let!(:order_item) { FactoryGirl.create(:order_item, order: order) }

        it 'redirects to the order show page' do
          delete :destroy, id: order_item
          expect(response).to redirect_to order_path(order)
        end

        it 'does not remove the order item record' do
          expect do
            delete :destroy, id: order_item
          end.not_to change(OrderItem, :count)
        end
      end
    end

    context 'for a submitted order' do
      let!(:order) { FactoryGirl.create(:submitted_order) }
      include_examples 'an immutable order'
    end

    context 'for an exported order' do
      let!(:order) { FactoryGirl.create(:exported_order) }
      include_examples 'an immutable order'
    end

    context 'for a processing order' do
      let!(:order) { FactoryGirl.create(:processing_order) }
      include_examples 'an immutable order'
    end

    context 'for a shipped order' do
      let!(:order) { FactoryGirl.create(:shipped_order) }
      include_examples 'an immutable order'
    end

    context 'for a rejected order' do
      let!(:order) { FactoryGirl.create(:rejected_order) }
      include_examples 'an immutable order'
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #new" do
      it 'redirects to the sign in page' do
        get :new, order_id: order
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'POST #create' do
      it 'redirects to the sign in page' do
        post :create, order_id: order, order_item: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create an order item record' do
        expect do
          post :create, order_id: order, order_item: attributes
        end.not_to change(order.items, :count)
      end
    end

    describe "GET #edit" do
      it 'redirects to the sign in page' do
        get :edit, id: order_item
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'PATCH #update' do
      it 'redirects to the sign in page' do
        patch :update, id: order_item, order_item: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not update the order item record' do
        expect do
          patch :update, id: order_item, order_item: attributes
          order_item.reload
        end.not_to change(order_item, :quantity)
      end
    end

    describe 'DELETE #destroy' do
      let!(:order_item) { FactoryGirl.create(:order_item, order: order) }

      it 'redirects to the sign in page' do
        delete :destroy, id: order_item
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not remove the order item record' do
        expect do
          delete :destroy, id: order_item
        end.not_to change(order.items, :count)
      end
    end
  end
end

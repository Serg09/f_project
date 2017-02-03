require 'rails_helper'

RSpec.describe ShipmentItemsController, type: :controller do
  let!(:product_1) { FactoryGirl.create :product, sku: '123456' }
  let!(:product_2) { FactoryGirl.create :product, sku: '654321' }
  let (:order) do
    FactoryGirl.create :processing_order,
      item_attributes: [
        {
          sku: '123456',
          quantity: 2
        },
        {
          sku: '654321',
          quantity: 1
        }
      ]
  end
  let (:order_item_1) do
    order.items.select{|i| i.sku == product_1.sku}.first
  end
  let (:order_item_2) do
    order.items.select{|i| i.sku == product_2.sku}.first
  end
  let (:shipment) { FactoryGirl.create :shipment, order: order }
  let (:attributes) do
    {
      order_item_id: order_item_1.id,
      external_line_no: 1,
      shipped_quantity: 2
    }
  end
  before { order.items.select(&:standard_item?).each{|i| i.acknowledge!} }

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

    describe 'POST #create' do
      it 'creates the shipment item record' do
        expect do
          post :create, shipment_id: shipment, shipment_item: attributes
        end.to change(shipment.items, :count).by(1)
      end

      context 'when the order item still has unshipped quantity' do
        let (:partial_attributes) do
          attributes.merge shipped_quantity: 1
        end

        it 'updates the item status to "partially shipped"' do
          expect do
            post :create, shipment_id: shipment, shipment_item: partial_attributes
            order_item_1.reload
          end.to change(order_item_1, :status).from('processing').to('partially_shipped')
        end
      end

      context 'when the order item is completely shipped' do
        it 'updates the item status to "shipped"' do
          expect do
            post :create, shipment_id: shipment, shipment_item: attributes
            order_item_1.reload
          end.to change(order_item_1, :status).from('processing').to('shipped')
        end
      end

      context 'when the last item in the order is shipped' do
        let (:attributes) do
          {
            order_item_id: order_item_2.id, shipped_quantity: 1,
            external_line_no: 2
          }
        end
        before do
          shipment.items.create! order_item_id: order_item_1.id,
            shipped_quantity: 2,
            external_line_no: 1
        end
        it 'redirects to the order show page' do
          post :create, shipment_id: shipment, shipment_item: attributes
          expect(response).to redirect_to order_path(order)
        end

        it 'updates the order status to "shipped"' do
          expect do
            post :create, shipment_id: shipment, shipment_item: attributes
            order.reload
          end.to change(order, :status).to('shipped')
        end
      end

      context 'when the order item is overshipped' do
        it 'shows a warning'
      end

      context 'when there are still unshipped items in the order' do
        it 'redirects to the shipment items page'
        it 'updates the order status to "partially shipped"'
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

    describe 'POST #create' do
      it 'redirects to the sign in page' do
        post :create, shipment_id: shipment, shipment_item: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create a shipment item record'
      it 'does not change the status of the order item'
      it 'does not change the status of the order'
    end
  end
end

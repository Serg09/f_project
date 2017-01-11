require 'rails_helper'

RSpec.describe Order, type: :model do
  let (:client) { FactoryGirl.create(:client) }
  let (:shipping_address) { FactoryGirl.create(:address) }
  let (:attributes) do
    {
      client_id: client.id,
      client_order_id: '000001',
      customer_name: 'John Doe',
      order_date: '2016-03-02',
      telephone: '214-555-1212',
      shipping_address_id: shipping_address.id
    }
  end
  let (:ship_method) { FactoryGirl.create :ship_method }

  it 'can be created from valid attributes' do
    order = Order.new attributes
    expect(order).to be_valid
  end

  it 'accepts nested attributes for shipping address' do
    shipping_address = FactoryGirl.attributes_for(:address)
    order = Order.new attributes.merge(
      shipping_address_attributes: shipping_address
    )
    expect(order.save).to be true
    expect(order.shipping_address.line_1).to eq shipping_address[:line_1]
  end

  describe '#client_id' do
    it 'is required' do
      order = Order.new attributes.except(:client_id)
      expect(order).to have_at_least(1).error_on :client_id
    end
  end

  describe '#client' do
    it 'refers to the client to which the order belongs' do
      order = Order.new attributes
      expect(order.client).to eq client
    end
  end

  describe '#client_order_id' do
    it 'must be unique' do
      o1 = Order.create! attributes
      o2 = Order.new attributes
      expect(o2).to have(1).error_on :client_order_id
    end

    it 'cannot be more than 100 characters' do
      order = Order.new attributes.merge(client_order_id: 'X' * 101)
      expect(order).to have_at_least(1).error_on :client_order_id
    end
  end

  describe '#customer_name' do
    it 'can be 50 characters' do
      order = Order.new attributes.merge(customer_name: 'x' * 50)
      expect(order).to be_valid
    end

    it 'cannot be more than 50 characters' do
      order = Order.new attributes.merge(customer_name: 'x' * 51)
      expect(order).to have_at_least(1).error_on :customer_name
    end
  end

  describe '#customer_email' do
    it 'cannot be more than 100 characters' do
      order = Order.new attributes.merge(customer_email: 'X' * 101)
      expect(order).to have_at_least(1).error_on :customer_email
    end
  end

  describe '#telephone' do
    it 'can be 25 characters' do
      order = Order.new attributes.merge(telephone: 'x' * 25)
      expect(order).to be_valid
    end

    it 'cannot be more than 25 characters' do
      order = Order.new attributes.merge(telephone: 'x' * 26)
      expect(order).to have_at_least(1).error_on :telephone
    end
  end

  describe '#order_date' do
    it 'is required' do
      order = Order.new attributes.except(:order_date)
      expect(order).to have_at_least(1).error_on :order_date
    end
  end

  describe '#abbreviated_confirmation' do
    let (:order) { Order.new attributes.merge confirmation: 'abcd123456789012345679012345678' }
    it 'is the first 8 characters of the full confirmation, separated with a hyphen' do
      expect(order.abbreviated_confirmation).to eq 'ABCD-1234'
    end
  end

  describe '#items' do
    it 'is a list of items in the order' do
      order = Order.new attributes
      expect(order).to have(0).items
    end
  end

  context '#ship_method' do
    let (:order) { Order.new attributes.merge(ship_method_id: ship_method.id) }

    it 'is a reference to the method selected for deliverying the order to the purchase' do
      expect(order.ship_method).to eq ship_method
    end
  end

  context '#update_freight_charge!' do
    let (:product) { FactoryGirl.create(:product) }
    before do
      order.add_item product.sku, 2
      order.update_freight_charge!
    end
    context 'when ship_method is nil' do
      let (:order) { Order.create! attributes }
      it 'is nil' do
        expect(order.freight_charge).to be_nil
      end
    end

    context 'when ship_method is not nil' do
      let (:order) do
        Order.create! attributes.merge(ship_method_id: ship_method.id)
      end
      it 'reflects the cost of shipping the items in the order' do
        expect(order.freight_charge).to eq 5
      end
    end

    context 'when the last item is removed' do
      let (:order) do
        Order.create! attributes.merge(ship_method_id: ship_method.id)
      end
      before { order.add_item product.sku }
      it 'removes the shipping item' do
        expect do
          order.items.first.destroy!
        end.to change(order.items, :count).by(-2)
      end
    end
  end

  describe '#all_items_shipped?' do
    let (:order) { FactoryGirl.create(:processing_order, item_count: 1) }
    let (:item) { order.items.first }
    context 'when all items have been shipped' do
      before { item.acknowledge!; item.ship! }
      it 'returns true' do
        expect(order).to be_all_items_shipped
      end
    end

    context 'when at least one item has not been shipped' do
      it 'returns false' do
        expect(order).not_to be_all_items_shipped
      end
    end
  end

  describe '#shipments' do
    it 'is a list of shipments in fulfillment of the order' do
      order = Order.new attributes
      expect(order).to have(0).shipments
    end
  end

  describe '#total' do
    let (:order) { FactoryGirl.create(:order) }
    let!(:i1) do FactoryGirl.create(:order_item, order: order,
                                                 quantity: 1,
                                                 unit_price: 20,
                                                 tax: 1.5)
    end
    let!(:i2) do FactoryGirl.create(:order_item, order: order,
                                                 quantity: 1,
                                                 unit_price: 30,
                                                 tax: nil)
    end

    it 'is the sum of the line item totals' do
      expect(order.total).to eq 56.50 # includes $5 FREIGHT line item, added automatically
    end
  end

  describe '#batch' do
    let (:batch) { FactoryGirl.create(:batch) }
    let (:order) { FactoryGirl.create(:order, batch: batch) }

    it 'is a reference to the batch to which the order belongs' do
      expect(order.batch).to eq batch
    end
  end

  describe '#acknowledge' do
    let (:order) { FactoryGirl.create(:exported_order) }
    it 'changes the status to "processing"' do
      expect do
        order.acknowledge
      end.to change(order, :status).from('exported').to('processing')
    end
  end

  describe '#add_item' do
    let!(:product) { FactoryGirl.create(:product) }
    let (:order) { FactoryGirl.create(:incipient_order) }

    context 'with a valid SKU' do
      it 'adds an item to the order' do
        expect do
          order.add_item product.sku
        end.to change(order.items, :count).by(2)
        # add FREIGHT item automatically
      end

      it 'returns the item' do
        item = order.add_item product.sku
        expect(item).not_to be_nil
        expect(item).to be_a OrderItem
      end

      it 'set the description based on the specified product' do
        item = order.add_item product.sku
        expect(item.description).to eq product.description
      end

      it 'sets the price based on the specified product' do
        item = order.add_item product.sku
        expect(item.unit_price).to eq product.price
      end

      it 'defaults to a quantity of 1' do
        item = order.add_item product.sku
        expect(item.quantity).to eq 1
      end
    end

    context 'with an invalid SKU' do
      it 'does not add an item to the order' do
        expect do
          order.add_item 'notavalidsku'
        end.not_to change(order.items, :count)
      end

      it 'returns nil' do
        expect(order.add_item('notavalidsku')).to be_nil
      end
    end
  end

  describe '#<<' do
    let (:order) { FactoryGirl.create(:incipient_order) }
    let (:sku) { '1234567890123' }
    let!(:product) { FactoryGirl.create(:product, sku: sku) }

    it 'adds a item to the order' do
      expect do
        order << sku
      end.to change(order.items, :count).by(2)
      # adds FREIGHT item automatically
    end

    it 'returns the new item' do
      item = order << sku
      expect(item).to be_a OrderItem
      expect(item.sku).to eq sku
      expect(item.quantity).to eq 1
    end
  end

  describe '::by_order_date' do
    let!(:o1) { FactoryGirl.create(:order, order_date: '2016-01-01') }
    let!(:o2) { FactoryGirl.create(:order, order_date: '2016-02-01') }

    it 'returns the order by order date descending' do
      expect(Order.by_order_date.map(&:id)).to eq [o2.id, o1.id]
    end
  end

  describe '::unbatched' do
    let (:batch) { FactoryGirl.create(:batch) }
    let!(:o1) { FactoryGirl.create(:order, batch: batch) }
    let!(:o2) { FactoryGirl.create(:order) }
    let!(:o3) { FactoryGirl.create(:order, batch: batch) }
    let!(:o4) { FactoryGirl.create(:order) }

    it 'returns a list of orders that have not been assigned to a batch' do
      expect(Order.unbatched.map(&:id)).to contain_exactly o2.id, o4.id
    end
  end

  shared_examples 'an immutable order' do
    describe 'updatable?' do
      it 'returns false' do
        expect(order).not_to be_updatable
      end
    end
  end

  shared_examples 'a submittable order' do
    describe '#submit' do
      it 'returns true' do
        expect(order.submit).to be true
      end

      it 'changes the state to "submitted"' do
        expect do
          order.submit
        end.to change(order, :status).to('submitted')
      end

      it 'sets the confirmation value' do
        expect do
          order.submit
        end.to change(order, :confirmation).from(nil)
      end
    end
  end

  shared_examples 'an unsubmittable order' do
    describe '#submit' do
      it 'returns false' do
        expect(order.submit).to be false
      end

      it 'does not change the state' do
        expect do
          order.submit
        end.not_to change(order, :status)
      end
    end
  end

  shared_examples 'an exportable order' do
    describe '#export' do
      it 'returns true' do
        expect(order.export).to be true
      end

      it 'changes the status to "exported"' do
        expect do
          order.export
        end.to change(order, :status).to('exporting')
      end
    end
  end

  shared_examples 'an unexportable order' do
    describe '#export' do
      it 'returns false' do
        expect(order.export).to be false
      end

      it 'does not changes the status' do
        expect do
          order.export
        end.not_to change(order, :status)
      end
    end
  end

  context 'that is incipient' do
    let (:order) { FactoryGirl.create(:incipient_order) }

    describe 'updatable?' do
      it 'returns true' do
        expect(order).to be_updatable
      end
    end

    include_examples 'an unexportable order'

    context 'and requires physical delivery' do
      let (:product) { FactoryGirl.create :product }
      before{ order << product }

      context 'and is ready for submission' do
        include_examples 'a submittable order'
      end

      context 'but does not have a shipping address' do
        before { order.shipping_address_id = nil }
        include_examples 'an unsubmittable order'
      end

      context 'but does not have a telephone number' do
        before { order.telephone = nil }
        include_examples 'an unsubmittable order'
      end
    end

    context 'and requires electronic delivery' do
      let (:product) { FactoryGirl.create :electronic_product }
      before{ order << product }

      context 'and is ready for submission' do
        before { order.delivery_email = Faker::Internet.email }

        include_examples 'a submittable order'
      end

      context 'but does not have a delivery email address' do
        before { order.delivery_email = nil }
        include_examples 'an unsubmittable order'
      end
    end

    context 'but does not have any items' do
      include_examples 'an unsubmittable order'
    end

    context 'but does not have a customer name' do
      before { order.customer_name = nil }
      include_examples 'an unsubmittable order'
    end
  end

  context 'that is submitted' do
    let (:order ) { FactoryGirl.create :submitted_order }
    include_examples 'an immutable order'
    include_examples 'an unsubmittable order'
    include_examples 'an exportable order'
  end

  context 'that is exported' do
    let (:order) { FactoryGirl.create :exported_order }
    include_examples 'an immutable order'
    include_examples 'an unsubmittable order'
    include_examples 'an unexportable order'
  end

  context 'that is processing' do
    let (:order) { FactoryGirl.create :processing_order }
    include_examples 'an immutable order'
    include_examples 'an unsubmittable order'
    include_examples 'an unexportable order'
  end

  context 'that is shipped' do
    let (:order) { FactoryGirl.create :shipped_order }
    include_examples 'an immutable order'
    include_examples 'an unsubmittable order'
    include_examples 'an unexportable order'
  end

  context 'that is rejected' do
    let (:order) { FactoryGirl.create :rejected_order }
    include_examples 'an immutable order'
    include_examples 'an unsubmittable order'
    include_examples 'an unexportable order'
  end
end

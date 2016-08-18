require 'rails_helper'

RSpec.describe Order, type: :model do
  let (:client) { FactoryGirl.create(:client) }
  let (:attributes) do
    {
      client_id: client.id,
      client_order_id: '000001',
      customer_name: 'John Doe',
      address_1: '1234 MAIN ST',
      address_2: 'APT 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75200',
      country_code: 'US',
      order_date: '2016-03-02',
      telephone: '214-555-1212'
    }
  end

  it 'can be created from valid attributes' do
    order = Order.new attributes
    expect(order).to be_valid
  end

  describe '#client_id' do
    it 'is required' do
      order = Order.new attributes.except(:client_id)
      expect(order).to have_at_least(1).error_on :client_id
    end

    it 'cannot be more than 100 characters' do
      order = Order.new attributes.merge(client_order_id: 'X' * 101)
      expect(order).to have_at_least(1).error_on :client_order_id
    end
  end

  describe '#client' do
    it 'refers to the client to which the order belongs' do
      order = Order.new attributes
      expect(order.client).to eq client
    end
  end

  describe '#client_order_id' do
    it 'is required' do
      order = Order.new attributes.except(:client_order_id)
      expect(order).to have_at_least(1).error_on :client_order_id
    end
  end

  describe '#customer_name' do
    it 'is required' do
      order = Order.new attributes.except(:customer_name)
      expect(order).to have_at_least(1).error_on :customer_name
    end

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

  describe '#address_1' do
    it 'is required' do
      order = Order.new attributes.except(:address_1)
      expect(order).to have_at_least(1).error_on :address_1
    end

    it 'can be 50 characters' do
      order = Order.new attributes.merge(address_1: 'x' * 50)
      expect(order).to be_valid
    end

    it 'cannot be more than 50 characters' do
      order = Order.new attributes.merge(address_1: 'x' * 51)
      expect(order).to have_at_least(1).error_on :address_1
    end
  end

  describe '#address_2' do
    it 'can be 50 characters' do
      order = Order.new attributes.merge(address_2: 'x' * 50)
      expect(order).to be_valid
    end

    it 'cannot be more than 50 characters' do
      order = Order.new attributes.merge(address_2: 'x' * 51)
      expect(order).to have_at_least(1).error_on :address_2
    end
  end

  describe '#city' do
    it 'is required' do
      order = Order.new attributes.except(:city)
      expect(order).to have_at_least(1).error_on :city
    end

    it 'can be 50 characters' do
      order = Order.new attributes.merge(city: 'x' * 50)
      expect(order).to be_valid
    end

    it 'cannot be more than 50 characters' do
      order = Order.new attributes.merge(city: 'x' * 51)
      expect(order).to have_at_least(1).error_on :city
    end
  end

  describe '#state' do
    it 'is required' do
      order = Order.new attributes.except(:state)
      expect(order).to have_at_least(1).error_on :state
    end

    it 'cannot be more than 100 characters' do
      order = Order.new attributes.merge(state: 'x' * 101)
      expect(order).to have_at_least(1).error_on :state
    end
  end

  describe '#postal_code' do
    it 'is required' do
      order = Order.new attributes.except(:postal_code)
      expect(order).to have_at_least(1).error_on :postal_code
    end

    it 'can be 10 characters' do
      order = Order.new attributes.merge(postal_code: 'x' * 10)
      expect(order).to be_valid
    end

    it 'cannot be more than 10 characters' do
      order = Order.new attributes.merge(postal_code: 'x' * 11)
      expect(order).to have_at_least(1).error_on :postal_code
    end
  end

  describe '#country_code' do
    it 'is required' do
      order = Order.new attributes.except(:country_code)
      expect(order).to have_at_least(1).error_on :country_code
    end

    it 'can be 3 characters' do
      order = Order.new attributes.merge(country_code: 'x' * 3)
      expect(order).to be_valid
    end

    it 'cannot be more than 3 characters' do
      order = Order.new attributes.merge(country_code: 'x' * 4)
      expect(order).to have_at_least(1).error_on :country_code
    end

    it 'cannot be less than 2 characters' do
      order = Order.new attributes.merge(country_code: 'x')
      expect(order).to have_at_least(1).error_on :country_code
    end
  end

  describe '#telephone' do
    it 'is required' do
      order = Order.new attributes.except(:telephone)
      expect(order).to have_at_least(1).error_on :telephone
    end

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

  describe '#items' do
    it 'is a list of items in the order' do
      order = Order.new attributes
      expect(order).to have(0).items
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
                                                 price: 20,
                                                 freight_charge: 3,
                                                 tax: 1.5)
    end
    let!(:i2) do FactoryGirl.create(:order_item, order: order,
                                                 quantity: 1,
                                                 price: 30,
                                                 freight_charge: nil,
                                                 tax: nil)
    end

    it 'is the sum of the line item totals' do
      expect(order.total).to eq 54.50
    end
  end

  describe '#batch' do
    let (:batch) { FactoryGirl.create(:batch) }
    let (:order) { FactoryGirl.create(:order, batch: batch) }

    it 'is a reference to the batch to which the order belongs' do
      expect(order.batch).to eq batch
    end
  end

  describe '#export' do
    let (:order) { FactoryGirl.create(:order) }
    it 'changes the status to "exported"' do
      expect do
        order.export
      end.to change(order, :status).from('new').to('exported')
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

  describe '#<<' do
    let (:order) { FactoryGirl.create(:new_order) }
    let (:sku) { '1234567890123' }

    it 'adds a item to the order' do
      expect do
        order << sku
      end.to change(order.items, :count).by(1)
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

  context 'that is new' do
    let (:order) { FactoryGirl.create(:new_order) }

    describe 'updatable?' do
      it 'returns true' do
        expect(order).to be_updatable
      end
    end
  end

  context 'that is exported' do
    it_behaves_like 'an immutable order' do
      let (:order) { FactoryGirl.create(:exported_order) }
    end
  end

  context 'that is processing' do
    it_behaves_like 'an immutable order' do
      let (:order) { FactoryGirl.create(:processing_order) }
    end
  end

  context 'that is shipped' do
    it_behaves_like 'an immutable order' do
      let (:order) { FactoryGirl.create(:shipped_order) }
    end
  end

  context 'that is rejected' do
    it_behaves_like 'an immutable order' do
      let (:order) { FactoryGirl.create(:rejected_order) }
    end
  end
end

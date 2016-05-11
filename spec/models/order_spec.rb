require 'rails_helper'

RSpec.describe Order, type: :model do
  let (:attributes) { FactoryGirl.attributes_for(:order) }

  it 'can be created from valid attributes' do
    order = Order.new attributes
    expect(order).to be_valid
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

    it 'can be 2 characters' do
      order = Order.new attributes.merge(state: 'x' * 2)
      expect(order).to be_valid
    end

    it 'cannot be more than 2 characters' do
      order = Order.new attributes.merge(state: 'x' * 3)
      expect(order).to have_at_least(1).error_on :state
    end

    it 'cannot be less than 2 characters' do
      order = Order.new attributes.merge(state: 'x')
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
end

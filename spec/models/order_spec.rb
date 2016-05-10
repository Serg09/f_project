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

    it 'can be 20 characters' do
      order = Order.new attributes.merge(telephone: 'x' * 20)
      expect(order).to be_valid
    end

    it 'cannot be more than 15characters' do
      order = Order.new attributes.merge(telephone: 'x' * 21)
      expect(order).to have_at_least(1).error_on :telephone
    end
  end
end

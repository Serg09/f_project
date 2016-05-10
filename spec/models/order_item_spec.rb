require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  let (:order) { FactoryGirl.create(:order) }
  let (:attributes) do
    {
      order_id: order.id,
      sku: 'ABC123',
      quantity: 1,
      description: 'My Book',
      price: 19.99,
      discount_percentage: 0.0,
      freight_charge: 2.99,
      tax: 1.65
    }
  end

  it 'can be created from valid attributes' do
    item = OrderItem.new attributes
    expect(item).to be_valid
  end

  describe '#order_id' do
    it 'is required' do
      item = OrderItem.new attributes.except(:order_id)
      expect(item).to have_at_least(1).error_on :order_id
    end
  end

  describe '#order' do
    it 'is a reference to the order to which the item belongs' do
      item = OrderItem.new attributes
      expect(item.order).to eq order
    end
  end

  describe '#line_item_no' do
    it 'is automatically set to the next available value' do
      item = OrderItem.create! attributes
      expect(item.line_item_no).to eq 1
    end
  end

  describe '#sku' do
    it 'is required' do
      item = OrderItem.new attributes.except(:sku)
      expect(item).to have_at_least(1).error_on :sku
    end

    it 'cannot be more than 30 characters' do
      item = OrderItem.new attributes.merge(sku: 'x' * 31)
      expect(item).to have_at_least(1).error_on :sku
    end

    it 'is unique within the order' do
      i1 = OrderItem.create! attributes
      i2 = OrderItem.new attributes
      expect(i2).to have_at_least(1).error_on :sku
    end

    it 'can be duplicated across orders' do
      i1 = OrderItem.create! attributes
      i2 = OrderItem.new attributes.merge(order_id: FactoryGirl.create(:order).id)
      expect(i2).to be_valid
    end
  end

  describe '#description' do
    it 'cannot be longer than 50 characters' do
      item = OrderItem.new attributes.merge(description: 'x' * 51)
      expect(item).to have_at_least(1).error_on :description
    end
  end

  describe '#quantity' do
    it 'is required' do
      item = OrderItem.new attributes.except(:quantity)
      expect(item).to have_at_least(1).error_on :quantity
    end

    context 'on create' do
      it 'must be greater than zero' do
        item = OrderItem.new attributes.merge(quantity: 0)
        expect(item).to have_at_least(1).error_on :quantity
      end
    end

    context 'on update' do
      it 'can be zero' do
        item = OrderItem.create! attributes
        item.quantity = 0
        expect(item).to be_valid
      end

      it 'cannot be less than 0' do
        item = OrderItem.create! attributes
        item.quantity = -1
        expect(item).to have_at_least(1).error_on :quantity
      end
    end
  end

  describe '#price' do
    it 'cannot be less than' do
      item = OrderItem.new attributes.merge(price: -0.01)
      expect(item).to have_at_least(1).error_on :price
    end
  end

  describe '#discount_percentage' do
    it 'cannot be less than zero' do
      item = OrderItem.new attributes.merge(discount_percentage: -0.01)
      expect(item).to have_at_least(1).error_on :discount_percentage
    end
  end

  describe '#freight_charge' do
    it 'cannot be less than zero' do
      item = OrderItem.new attributes.merge(freight_charge: -0.01)
      expect(item).to have_at_least(1).error_on :freight_charge
    end
  end

  describe '#tax' do
    it 'cannot be less than zero' do
      item = OrderItem.new attributes.merge(tax: -0.01)
      expect(item).to have_at_least(1).error_on :tax
    end
  end
end

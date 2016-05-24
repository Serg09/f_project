require 'rails_helper'

RSpec.describe ShipmentItem, type: :model do
  let (:sku) { Faker::Code.isbn }
  let (:order) { FactoryGirl.create(:order) }
  let (:order_item) { FactoryGirl.create(:order_item, order: order, sku: sku) }
  let (:shipment) { FactoryGirl.create(:shipment, order: order) }
  let (:attributes) do
    {
      shipment_id: shipment.id,
      order_item_id: order_item.id,
      external_line_no: 1,
      sku: sku,
      price: 19.99,
      shipped_quantity: 1
    }
  end

  it 'can be created from valid attributes' do
    item = ShipmentItem.new attributes
    expect(item).to be_valid
  end

  describe '#shipment_id' do
    it 'is required' do
      item = ShipmentItem.new attributes.except(:shipment_id)
      expect(item).to have_at_least(1).error_on :shipment_id
    end
  end

  describe '#shipment' do
    it 'is a reference to the shipment to which the item belongs' do
      item = ShipmentItem.new attributes
      expect(item.shipment).to eq shipment
    end
  end

  describe '#order_item_id' do
    it 'is required' do
      item = ShipmentItem.new attributes.except(:order_item_id)
      expect(item).to have_at_least(1).error_on :order_item_id
    end
  end

  describe '#order_item' do
    it 'is a reference to the order item to which the item belongs' do
      item = ShipmentItem.new attributes
      expect(item.order_item).to eq order_item
    end
  end

  describe '#shipped_quantity' do
    it 'is required' do
      item = ShipmentItem.new attributes.except(:shipped_quantity)
      expect(item).to have_at_least(1).error_on :shipped_quantity
    end
  end

  describe '#packages' do
    it 'is a list of packages associated with the item' do
      item = ShipmentItem.new attributes
      expect(item).to have(0).packages
    end
  end
end

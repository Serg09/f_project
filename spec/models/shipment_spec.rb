require 'rails_helper'

RSpec.describe Shipment, type: :model do
  let (:order) { FactoryGirl.create(:order) }
  let (:attributes) do
    {
      order_id: order.id,
      external_id: 'shipment1',
      ship_date: Date.parse('2016-03-02'),
      quantity: 1
    }
  end

  it 'can be created from valid attributes' do
    shipment = Shipment.new attributes
    expect(shipment).to be_valid
  end

  describe '#order_id' do
    it 'is required' do
      shipment = Shipment.new attributes.except(:order_id)
      expect(shipment).to have_at_least(1).error_on :order_id
    end
  end

  describe '#order' do
    it 'is a reference to the order' do
      shipment = Shipment.new attributes
      expect(shipment.order).to eq order
    end
  end

  describe '#external_id' do
    it 'is required' do
      shipment = Shipment.new attributes.except(:external_id)
      expect(shipment).to have_at_least(1).error_on :external_id
    end
  end

  describe '#ship_date' do
    it 'is required' do
      shipment = Shipment.new attributes.except(:ship_date)
      expect(shipment).to have_at_least(1).error_on :ship_date
    end
  end

  describe '#quantity' do
    it 'is required' do
      shipment = Shipment.new attributes.except(:quantity)
      expect(shipment).to have_at_least(1).error_on :quantity
    end
  end

  describe '#items' do
    it 'is a list of items in the shipment' do
      shipment = Shipment.new attributes
      expect(shipment).to have(0).items
    end
  end
end

require 'rails_helper'

RSpec.describe Package, type: :model do
  let (:shipment_item) { FactoryGirl.create(:shipment_item) }
  let (:attributes) do
    {
      shipment_item_id: shipment_item.id,
      package_id: 'ABC123',
      tracking_number: 'DEF456',
      quantity: 1,
      weight: 5.23
    }
  end

  it 'can be created with valid attributes' do
    package = Package.new attributes
    expect(package).to be_valid
  end

  describe '#shipment_item_id' do
    it 'is required' do
      package = Package.new attributes.except(:shipment_item_id)
      expect(package).to have_at_least(1).error_on :shipment_item_id
    end
  end

  describe '#shipment_item' do
    it 'is a reference to the shipment item to which the package belongs' do
      package = Package.new attributes
      expect(package.shipment_item).to eq shipment_item
    end
  end
end

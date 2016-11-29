require 'rails_helper'

RSpec.describe ShipMethod, type: :model do
  let (:carrier) { FactoryGirl.create :carrier }
  let (:attributes) do
    {
      carrier_id: carrier.id,
      description: 'Really Fast',
      abbreviation: 'RF'
    }
  end

  it 'can be created from valid attributes' do
    ship_method = ShipMethod.new attributes
    expect(ship_method).to be_valid
  end

  describe '#carrier_id' do
    it 'is required'
  end

  describe '#carrier' do
    it 'is a reference to the carrier'
  end

  describe '#description' do
    it 'is required'
    it 'can be 100 characters'
    it 'cannot be more than 100 characters'
    it 'is unique for a carrier'
    it 'can be duplicated across carriers'
  end

  describe '#abbreviation' do
    it 'is required'
    it 'is unique'
    it 'can be 20 characters'
    it 'cannot be more than 20 characters'
  end
end

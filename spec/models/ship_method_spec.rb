require 'rails_helper'

RSpec.describe ShipMethod, type: :model do
  let (:carrier) { FactoryGirl.create :carrier }
  let (:other_carrier) { FactoryGirl.create :carrier }
  let (:attributes) do
    {
      carrier_id: carrier.id,
      description: 'Really Fast',
      abbreviation: 'RF',
      calculator_class: 'TestShipMethodCalculator'
    }
  end

  it 'can be created from valid attributes' do
    ship_method = ShipMethod.new attributes
    expect(ship_method).to be_valid
  end

  describe '#carrier_id' do
    it 'is required' do
      ship_method = ShipMethod.new attributes.except(:carrier_id)
      expect(ship_method).to have(1).error_on(:carrier_id)
    end
  end

  describe '#carrier' do
    it 'is a reference to the carrier' do
      ship_method = ShipMethod.new attributes
      expect(ship_method.carrier).to eq(carrier)
    end
  end

  describe '#description' do
    it 'is required' do
      ship_method = ShipMethod.new attributes.except(:description)
      expect(ship_method).to have(1).error_on(:description)
    end

    it 'can be 100 characters' do
      ship_method = ShipMethod.new attributes.merge(description: 'x' * 100)
      expect(ship_method).to be_valid
    end

    it 'cannot be more than 100 characters' do
      ship_method = ShipMethod.new attributes.merge(description: 'x' * 101)
      expect(ship_method).to have(1).error_on(:description)
    end

    it 'is unique for a carrier' do
      sm1 = ShipMethod.create! attributes
      sm2 = ShipMethod.new attributes
      expect(sm2).to have(1).error_on(:description)
    end

    it 'can be duplicated across carriers' do
      sm1 = ShipMethod.create! attributes
      sm2 = ShipMethod.new attributes.merge(carrier_id: other_carrier.id,
                                            abbreviation: Faker::Hacker.abbreviation)
      expect(sm2).to be_valid
    end
  end

  describe '#abbreviation' do
    it 'is required' do
      ship_method = ShipMethod.new attributes.except(:abbreviation)
      expect(ship_method).to have(1).error_on(:abbreviation)
    end

    it 'is unique for a given carrier' do
      sm1 = ShipMethod.create! attributes
      sm2 = ShipMethod.new attributes
      expect(sm2).to have(1).error_on(:abbreviation)
    end

    it 'is unique for across carriers' do
      sm1 = ShipMethod.create! attributes
      sm2 = ShipMethod.new attributes.merge(carrier_id: other_carrier.id)
      expect(sm2).to have(1).error_on(:abbreviation)
    end

    it 'can be 20 characters' do
      ship_method = ShipMethod.new attributes.merge(abbreviation: 'x' * 20)
      expect(ship_method).to be_valid
    end

    it 'cannot be more than 20 characters' do
      ship_method = ShipMethod.new attributes.merge(abbreviation: 'x' * 21)
      expect(ship_method).to have(1).error_on(:abbreviation)
    end
  end

  describe '#calculator_class' do
    it 'is required' do
      ship_method = ShipMethod.new attributes.except(:calculator_class)
      expect(ship_method).to have(1).error_on(:calculator_class)
    end
  end

  describe '#calculate_charge' do
    let (:order) { FactoryGirl.create :order }

    it 'calculates the charge for the order' do
      ship_method = ShipMethod.new attributes
      expect(ship_method.calculate_charge(order)).to eq(5)
    end
  end
end

class TestShipMethodCalculator
  def calculate(order)
    5
  end
end

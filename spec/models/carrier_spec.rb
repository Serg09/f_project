require 'rails_helper'

RSpec.describe Carrier, type: :model do
  let (:attributes) do
    {
      name: 'ACME Shipping'
    }
  end

  it 'can be created from valid attributes' do
    carrier = Carrier.new attributes
    expect(carrier).to be_valid
  end

  describe '#name' do
    it 'is required' do
      carrier = Carrier.new attributes.except(:name)
      expect(carrier).to have(1).error_on :name
    end

    it 'can be 100 characters' do
      carrier = Carrier.new attributes.merge(name: 'x' * 100)
    expect(carrier).to be_valid
    end

    it 'cannot be more than 100 characters' do
      carrier = Carrier.new attributes.merge(name: 'x' * 101)
      expect(carrier).to have(1).error_on :name
    end

    it 'must be unique' do
      c1 = Carrier.create! attributes
      c2 = Carrier.new attributes
      expect(c2).to have(1).error_on :name
    end
  end
end

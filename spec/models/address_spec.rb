require 'rails_helper'

RSpec.describe Address, type: :model do
  let (:attributes) do
    {
      recipient: 'John Doe',
      line_1: '1234 Main St',
      line_2: 'Apt 227',
      city: 'Dallas', 
      state: 'TX',
      postal_code: '75200',
      country_code: 'US'
    }
  end

  it 'can be created from valid attributes' do
    address = Address.new attributes
    expect(address).to be_valid
  end

  describe '#line_1' do
    it 'is required' do
      address = Address.new attributes.except(:line_1)
      expect(address).to have(1).error_on(:line_1)
    end

    it 'cannot be more than 100 characters' do
      address = Address.new attributes.merge(line_1: 'x' * 101)
      expect(address).to have(1).error_on(:line_1)
    end
  end

  describe '#line_2' do
    it 'cannot be more than 100 characters' do
      address = Address.new attributes.merge(line_2: 'x' * 101)
      expect(address).to have(1).error_on(:line_2)
    end
  end

  describe '#city' do
    it 'is required' do
      address = Address.new attributes.except(:city)
      expect(address).to have(1).error_on(:city)
    end

    it 'cannot be more than 100 characters' do
      address = Address.new attributes.merge(city: 'x' * 101)
      expect(address).to have(1).error_on(:city)
    end
  end

  describe '#state' do
    it 'is required' do
      address = Address.new attributes.except(:state)
      expect(address).to have(1).error_on(:state)
    end

    it 'cannot be more than 20 characters' do
      address = Address.new attributes.merge(state: 'x' * 21)
      expect(address).to have(1).error_on(:state)
    end
  end

  describe '#postal_code' do
    it 'is required' do
      address = Address.new attributes.except(:postal_code)
      expect(address).to have(1).error_on(:postal_code)
    end

    it 'cannot be more than 10 characters' do
      address = Address.new attributes.merge(postal_code: 'x' * 11)
      expect(address).to have(1).error_on(:postal_code)
    end
  end

  describe '#country_code' do
    it 'is required' do
      address = Address.new attributes.except(:country_code)
      expect(address).to have(1).error_on(:country_code)
    end

    it 'cannot be more than 2 characters' do
      address = Address.new attributes.merge(country_code: 'x' * 3)
      expect(address).to have(1).error_on(:country_code)
    end
  end
end

require 'rails_helper'

RSpec.describe Client, type: :model do
  let (:attributes) do
    {
      name: 'ACME Books',
      abbreviation: 'acme'
    }
  end

  it 'can be created with valid attributes' do
    client = Client.new attributes
    expect(client).to be_valid
  end

  describe '#name' do
    it 'is required' do
      client = Client.new attributes.except(:name)
      expect(client).to have_at_least(1).error_on :name
    end

    it 'cannot be longer than 100 characters' do
      client = Client.new attributes.merge(name: 'A' * 101)
      expect(client).to have_at_least(1).error_on :name
    end

    it 'must be unique' do
      c1 = Client.create! attributes
      c2 = Client.new attributes
      expect(c2).to have_at_least(1).error_on :name
    end
  end

  describe '#abbreviation' do
    it 'is required' do
      client = Client.new attributes.except(:abbreviation)
      expect(client).to have_at_least(1).error_on :abbreviation
    end

    it 'cannot be longer than 5 characters' do
      client = Client.new attributes.merge(abbreviation: 'A' * 6)
      expect(client).to have_at_least(1).error_on :abbreviation
    end

    it 'must be unique' do
      c1 = Client.create! attributes
      c2 = Client.new attributes
      expect(c2).to have_at_least(1).error_on :abbreviation
    end
  end

  describe '#order_import_processor_class' do
    it 'cannot be longer than 250 characters' do
      client = Client.new attributes.merge(order_import_processor_class: 'X' * 251)
      expect(client).to have_at_least(1).error_on :order_import_processor_class
    end
  end
end

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

  describe '#auth_token' do
    it 'is set automatically' do
      client = Client.create! attributes
      expect(client.auth_token).not_to be_nil
    end
  end

  describe '#order_import_processor_class' do
    it 'cannot be longer than 250 characters' do
      client = Client.new attributes.merge(order_import_processor_class: 'X' * 251)
      expect(client).to have_at_least(1).error_on :order_import_processor_class
    end
  end

  describe '#book_identifier' do
    it 'is a list of book identifiers defined by the client' do
      client = Client.new attributes
      expect(client).to have(0).book_identifiers
    end
  end

  describe '#import_orders' do
    let (:client) { FactoryGirl.create(:client, order_import_processor_class: 'ThreeDM::OrderImporter') }
    let (:content) { 'this is fake content' }
    it 'invokes #process on an instance of the processor' do
      expect(ThreeDM::OrderImporter).to \
        receive(:new).
          with(content, client).
          and_call_original
      client.import_orders(content)
    end
  end

  describe '#orders' do
    let (:client) { FactoryGirl.create(:client) }

    it 'is a list of orders for the client' do
      expect(client).to have(0).orders
    end
  end

  describe '::order_importers' do
    let (:c1) { FactoryGirl.create(:client) }
    let (:c2) { FactoryGirl.create(:client, order_import_processor_class: 'SomeClass') }

    it 'returns a list of clients that have order importers defines' do
      expect(Client.order_importers).to eq [c2]
    end
  end
end

require 'rails_helper'

RSpec.describe BookIdentifier, type: :model do
  let (:book) { FactoryGirl.create(:book) }
  let (:client) { FactoryGirl.create(:client) }
  let (:attributes) do
    {
      book_id: book.id,
      client_id: client.id,
      code: 'WTF'
    }
  end

  it 'can be created from valid attributes' do
    identifier = BookIdentifier.new attributes
    expect(identifier).to be_valid
  end

  describe '#client_id' do
    it 'is required' do
      identifier = BookIdentifier.new attributes.except(:client_id)
      expect(identifier).to have_at_least(1).error_on :client_id
    end
  end

  describe '#client' do
    it 'is a reference to the client that defined the identifier' do
      identifier = BookIdentifier.new attributes
      expect(identifier.client).to eq client
    end
  end

  describe '#book_id' do
    it 'is required' do
      identifier = BookIdentifier.new attributes.except(:book_id)
      expect(identifier).to have_at_least(1).error_on :book_id
    end
  end

  describe '#book' do
    it 'is a reference to the book' do
      identifier = BookIdentifier.new attributes
      expect(identifier.book).to eq book
    end
  end

  describe '#code' do
    it 'is required' do
      identifier = BookIdentifier.new attributes.except(:code)
      expect(identifier).to have_at_least(1).error_on :code
    end

    it 'cannot be more than 20 characters' do
      identifier = BookIdentifier.new attributes.merge(code: 'X' * 21)
      expect(identifier).to have_at_least(1).error_on :code
    end
  end
end

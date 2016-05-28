require 'rails_helper'

RSpec.describe Book, type: :model do
  let (:attributes) do
    {
      isbn: '0123456789012',
      title: 'Some Stuff I Wrote',
      format: 'hard cover'
    }
  end

  it 'can be created from valid attributes' do
    book = Book.new(attributes)
    expect(book).to be_valid
  end

  describe '#isbn' do
    it 'is required' do
      book = Book.new attributes.except(:isbn)
      expect(book).to have_at_least(1).error_on :isbn
    end

    it 'cannot be more than 13 characters' do
      book = Book.new attributes.merge(isbn: '0' * 14)
      expect(book).to have_at_least(1).error_on :isbn
    end
  end

  describe '#title' do
    it 'is required' do
      book = Book.new attributes.except(:title)
      expect(book).to have_at_least(1).error_on :title
    end

    it 'cannot be more than 250 characters' do
      book = Book.new attributes.merge(title: '0' * 251)
      expect(book).to have_at_least(1).error_on :title
    end
  end

  describe '#format' do
    it 'is required' do
      book = Book.new attributes.except(:format)
      expect(book).to have_at_least(1).error_on :format
    end

    it 'cannot be more than 100 characters' do
      book = Book.new attributes.merge(format: '0' * 101)
      expect(book).to have_at_least(1).error_on :format
    end
  end
end

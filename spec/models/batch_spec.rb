require 'rails_helper'

RSpec.describe Batch, type: :model do
  it 'can be created without attributes' do
    batch = Batch.new
    expect(batch).to be_valid
  end

  describe '#status' do
    it 'defaults to "new"' do
      batch = Batch.new
      expect(batch.status).to eq Batch.NEW
    end

    it 'can be changed to "delivered"' do
      batch = Batch.create!
      batch.status = Batch.DELIVERED
      expect(batch).to be_valid
    end

    it 'can be changed to "acknowledged"' do
      batch = Batch.create!
      batch.status = Batch.ACKNOWLEDGED
      expect(batch).to be_valid
    end

    it 'cannot be anything other than "delivered", "acknowledged", or "new"' do
      batch = Batch.new status: 'somethingelse'
      expect(batch).to have_at_least(1).error_on :status
    end
  end

  describe '#orders' do
    it 'is a list of orders included in the batch' do
      batch = Batch.new
      expect(batch).to have(0).orders
    end
  end
end

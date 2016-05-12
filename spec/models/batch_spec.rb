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

  describe '::batch_orders' do
    let (:existing_batch) { FactoryGirl.create(:batch) }
    let!(:batched_order) { FactoryGirl.create(:order, batch: existing_batch) }

    let!(:o1) { FactoryGirl.create(:order, item_count: 1) }

    it 'creates a new batch' do
      expect do
        Batch.batch_orders
      end.to change(Batch, :count).by(1)
    end

    it 'returns the new batch' do
      batch = Batch.batch_orders
      expect(batch).not_to be_nil
      expect(batch).to be_a Batch
    end

    it 'adds unbatched orders to the batch' do
      batch = Batch.batch_orders
      expect(batch.orders.map(&:id)).to contain_exactly o1.id
    end

    it 'updates the batched orders' do
      expect do
        Batch.batch_orders
        o1.reload
      end.to change(o1, :batch_id).from(nil).to(Fixnum)
    end

    it 'does not change orders already batched' do
      expect do
        Batch.batch_orders
        batched_order.reload
      end.not_to change(batched_order, :batch_id)
    end
  end
end
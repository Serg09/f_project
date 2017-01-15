require 'rails_helper'

describe Lsi::PoaProcessor do
  let (:filename) { 'lsi_purchase_order_acknowledgment_sample.txt' }
  let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', filename)) }
  let (:processor) { Lsi::PoaProcessor.new(file_content) }

  let (:sku_1) { '1123456789' }
  let (:sku_2) { '123456987X' }
  let!(:product_1) { FactoryGirl.create(:product, sku: sku_1) }
  let!(:product_2) { FactoryGirl.create(:product, sku: sku_2) }
  let (:order1) { FactoryGirl.create(:exported_order, item_attributes: [{sku: sku_1}]) }
  let!(:item1_1) { order1.items.first }
  let (:order2) { FactoryGirl.create(:exported_order, item_attributes: [{sku: sku_1},{sku: sku_2}]) }
  let!(:item2_1) { order2.items.select{|i| i.sku == sku_1}.first }
  let!(:item2_2) { order2.items.select{|i| i.sku == sku_2}.first }
  let!(:batch) { FactoryGirl.create(:batch, orders: [order1, order2]) }


  describe '#process' do
    context 'for records without errors' do
      it 'updates the status of the order to "processing"' do
        expect do
          processor.process
          order1.reload
        end.to change(order1, :status).from('exported').to('processing')
      end

      it 'updates the status of the line items to "processing"' do
        expect do
          processor.process
          item1_1.reload
        end.to change(item1_1, :status).from('new').to('processing')
      end

      it 'sets the accepted_quantity' do
        expect do
          processor.process
          item1_1.reload
        end.to change(item1_1, :accepted_quantity).to(1)
      end
    end

    context 'for order error records' do
      let (:filename) { 'lsi_purchase_order_acknowledgment.txt' }
      it 'updates the status of the order to "rejected"' do
        expect do
          processor.process
          order2.reload
        end.to change(order2, :status).from('exported').to('rejected')
      end

      it 'updates the errors attribute of the order' do
        processor.process
        order2.reload
        expect(order2.error).to eq 'Unrecognized ISBN'
      end
    end

    context 'for item error records' do
      it 'updates the status of the item to "rejected"' do
        expect do
          processor.process
          item2_2.reload
        end.to change(item2_2, :status).from('new').to('rejected')
      end
    end
  end
end

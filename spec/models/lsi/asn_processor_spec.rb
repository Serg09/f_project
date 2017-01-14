require 'rails_helper'

describe Lsi::AsnProcessor do
  let!(:order1) { FactoryGirl.create(:processing_order, item_attributes: [{quantity: 50}]) }
  let (:order_item_1_1) { order1.items.first }
  let!(:order2) { FactoryGirl.create(:processing_order, item_attributes: [{quantity: 20}]) }
  let (:order_item_2_1) { order2.items.first }
  let!(:order3) { FactoryGirl.create(:processing_order) }
  let (:order_item_3_1) { order3.items.first }
  let!(:order4) { FactoryGirl.create(:processing_order) }
  let!(:order5) { FactoryGirl.create(:processing_order, item_attributes: (1..9).map{|i| {quantity: 1}}) }
  before do
    [order1,
     order2,
     order2,
     order4,
     order5].each do |order|
       order.items.select(&:standard_item?).each do |item|
         item.acknowledge!
       end
     end
  end

  let (:filename) { 'lsi_advanced_shipping_notification_sample.txt' }
  let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', filename)) }
  let (:processor) { Lsi::AsnProcessor.new(file_content) }

  describe '#process' do
    context 'with an order-level record' do
      it 'creates a shipment record' do
        expect do
          processor.process
        end.to change(Shipment, :count).by(4)
      end
    end
    context 'with an item-level record' do
      it 'creates a shipment item record' do
        expect do
          processor.process
        end.to change(ShipmentItem, :count).by(12)
      end

      it 'links the new shipment item record to the corresponding order item record' do
        processor.process
        expect(order_item_1_1).to have(1).shipment_item
      end

      context 'that completely fulfills the line item' do
        it 'updates the status of the corresponding order item to "shipped"' do
          expect do
            processor.process
            order_item_1_1.reload
          end.to change(order_item_1_1, :status).from('processing').to('shipped')
        end
      end

      context 'that partially fulfills the line item' do
        it 'updates the status of the corresponding order item to "partially_shipped"' do
          expect do
            processor.process
            order_item_2_1.reload
          end.to change(order_item_2_1, :status).from('processing').to('partially_shipped')
        end
      end
    end

    context 'with a package-level record' do
      it 'creates a shipment package record' do
        expect do
          processor.process
        end.to change(Package, :count).by(12)
      end

      it 'links the new package record to the shipment item record' do
        processor.process
        expect(order_item_1_1.shipment_items.first).to have(1).package
      end
    end
  end
end

require 'rails_helper'

describe Lsi::AsnProcessor do
  let (:filename) { 'lsi_advanced_shipping_notification_sample.txt' }
  let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', filename)) }
  let (:processor) { Lsi::AsnProcessor.new(file_content) }

  describe '#process' do
    context 'with an order-level record' do
      it 'creates a shipment record' do
        expect do
          processor.process
        end.to change(Shipment, :count).by(1)
      end
    end
    context 'with an item-level record' do
      it 'creates a shipment item record'
      it 'links the new shipment item record to the corresponding order item record'
      context 'that completely fulfills the line item' do
        it 'updates the status of the corresponding order item to "shipped"'
      end
      context 'that partially fulfills the line item' do
        it 'updates the status of the corresponding order item to "partially_shipped"'
      end
    end
    context 'with a package-level record' do
      it 'creates a shipment package record'
      it 'links the new package record to the shipment item record'
    end
  end
end

require 'rails_helper'

describe ThreeDM::OrderImporter do
  let (:client) { FactoryGirl.create(:client) }
  let (:content) { File.read(Rails.root.join('spec', 'fixtures', 'files', '3dm_orders.csv')) }
  let (:importer) { ThreeDM::OrderImporter.new(content, client) }

  describe '#process' do
    it 'creates the specified order records' do
      expect do
        importer.process
      end.to change(Order, :count).by(5)
    end

    it 'creates the specified order item records' do
      expect do
        importer.process
      end.to change(OrderItem, :count).by(14)
    end

    it 'resolves SKUs correctly'

    it 'consolodates line items having the same SKU'
  end
end

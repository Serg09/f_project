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
  end
end

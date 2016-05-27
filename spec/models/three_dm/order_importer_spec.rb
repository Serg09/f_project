require 'rails_helper'

describe ThreeDM::OrderImporter do
  let (:content) { File.read(Rails.root.join('spec', 'fixtures', 'files', '3dm_orders.csv')) }
  let (:importer) { ThreeDM::OrderImporter.new(content) }

  it 'creates the specified order records' do
    expect do
      importer.process
    end.to change(Order, :count).by(5)
  end
end

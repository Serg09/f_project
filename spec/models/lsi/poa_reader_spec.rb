require 'rails_helper'

describe Lsi::PoaReader do
  let (:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'lsi_purchase_order_acknowledgment_sample.txt') }
  let (:content) { File.read(file_path) }

  it 'yields record for each line in the file' do
    reader = Lsi::PoaReader.new(content)
    expect(reader.read).to have(7).items
  end
end

require 'rails_helper'

describe Lsi::PoaReader do
  let (:filename) { 'lsi_purchase_order_acknowledgment_sample.txt' }
  let (:file_path) { Rails.root.join('spec', 'fixtures', 'files', filename) }
  let (:content) { File.read(file_path) }
  let (:reader) { Lsi::PoaReader.new(content) }

  it 'yields record for each line in the file' do
    expect(reader.read).to have(7).items
  end

  it 'does not log warnings when things work well' do
    expect(Rails.logger).not_to receive(:warn)
    reader.read
  end

  context 'when the reported record count does not match the number of records' do
    let (:filename) { 'lsi_purchase_order_acknowledgment_missing_record.txt' }

    it 'warns if the number of recrds read does not match the batch footer' do
      expect(Rails.logger).to receive(:warn).with("The actual record count (4) does not match the reported record count (5)")
      reader.read
    end
  end
end

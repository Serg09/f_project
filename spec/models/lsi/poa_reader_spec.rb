require 'rails_helper'

describe Lsi::PoaReader do
  let (:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'lsi_purchase_order_acknowledgment.txt') }
  let (:content) { File.read(file_path) }

  it 'yields a sequence of records idenitying orders' do
    reader = Lsi::PoaReader.new(content)
    records = []
    reader.read do |record|
      records << record
    end
    expect(records).to eq [
      {
        batch_id: 1,
        order_id: 1,
        order_date: Date.new(2016, 2, 27)
      },
      {
        batch_id: 1,
        order_id: 2,
        order_date: Date.new(2016, 2, 28),
        errors: ["Unrecognized ISBN"]
      }
    ]
  end
end

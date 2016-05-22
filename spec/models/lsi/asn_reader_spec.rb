require 'rails_helper'

describe Lsi::AsnReader do
  let (:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'lsi_advanced_shipping_notification_sample.txt') }
  let (:content) { File.read(file_path) }
  let (:reader) { Lsi::AsnReader.new(content) }
  describe '#read' do
    it 'returns the batch header' do
      expected_header = {
          header: '$$HDR',
          client_id: 'PUBID',
          batch_id: 48897,
          batch_date_time: DateTime.parse('2001-10-19 17:37:03')
        }
      expect(reader.read.first).to eq expected_header
    end

    it 'returns the order-level records' do
      expect(reader.read.select{|r| r[:header] == 'O'}).to eq [
        {
          header: 'O',
          order_id: 1,
          lsi_order_id: 159414,
          shipment_id: 'MISCELLANEOUS',
          carrier_id: 'UPSGSRNA',
          ship_date: Date.parse('2001-10-19'),
          ship_quantity: 50,
          ship_weight: BigDecimal.new(18.69, 9),
          freight_amount: BigDecimal.new(6.96, 9),
          special_handling: BigDecimal.new(0, 9),
          freight_collect: 'N',
          freight_responsibility: 'P'
        },
        {
          header: 'O',
          order_id: 2,
          lsi_order_id: 159555,
          shipment_id: 'MISCELLANEOUS',
          carrier_id: 'XDHL',
          ship_date: Date.parse('2001-10-19'),
          ship_quantity: 10,
          ship_weight: BigDecimal.new(10.50, 9),
          freight_amount: BigDecimal.new(49.50, 9),
          special_handling: BigDecimal.new(0, 9),
          freight_collect: 'N',
          freight_responsibility: 'P'
        },
        {
          header: 'O',
          order_id: 3,
          lsi_order_id: 159566,
          shipment_id: 'MISCELLANEOUS',
          carrier_id: 'UPSGSRNA',
          ship_date: Date.parse('2001-10-19'),
          ship_quantity: 10,
          ship_weight: BigDecimal.new(10.00, 9),
          freight_amount: BigDecimal.new(6.37, 9),
          special_handling: BigDecimal.new(0, 9),
          freight_collect: 'N',
          freight_responsibility: 'P'
        },
        {
          header: 'O',
          order_id: 5,
          lsi_order_id: 159455,
          shipment_id: 'MISCELLANEOUS',
          carrier_id: 'UPSGSRNA',
          ship_date: Date.parse('2001-10-19'),
          ship_quantity: 9,
          ship_weight: BigDecimal.new(8.94, 9),
          freight_amount: BigDecimal.new(6.21, 9),
          special_handling: BigDecimal.new(0, 9),
          freight_collect: 'N',
          freight_responsibility: 'P'
        }
      ]
    end
  end
end

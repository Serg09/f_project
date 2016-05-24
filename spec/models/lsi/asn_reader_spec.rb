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

    it 'returns item-level records' do
      expect(reader.read.select{|r| r[:header] == 'I'}).to eq [
        {
          header: 'I',
          order_id: 1,
          line_item_no: 1,
          lsi_line_item_no: 1,
          sku_10: '0759635943',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 50
        },
        {
          header: 'I',
          order_id: 2,
          line_item_no: 1,
          lsi_line_item_no: 1,
          sku_10: '1588207781',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 10
        },
        {
          header: 'I',
          order_id: 3,
          line_item_no: 1,
          lsi_line_item_no: 1,
          sku_10: '0759643105',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 10
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 1,
          lsi_line_item_no: 1,
          sku_10: '0759643059',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 2,
          lsi_line_item_no: 2,
          sku_10: '1585001732',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 3,
          lsi_line_item_no: 3,
          sku_10: '1588204758',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 4,
          lsi_line_item_no: 4,
          sku_10: '1585005398',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 5,
          lsi_line_item_no: 5,
          sku_10: '1588208974',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 6,
          lsi_line_item_no: 6,
          sku_10: '1587210045',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 7,
          lsi_line_item_no: 7,
          sku_10: '1585004634',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 8,
          lsi_line_item_no: 8,
          sku_10: '0759639507',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        },
        {
          header: 'I',
          order_id: 5,
          line_item_no: 9,
          lsi_line_item_no: 9,
          sku_10: '1585005215',
          price: BigDecimal.new(0, 9),
          shipped_quantity: 1
        }
      ]
    end

    it 'returns the carton-level records' do
      expect(reader.read.select{|l| l[:header] == 'P'}).to eq [
        {
          header: 'P',
          order_id: 1,
          line_item_no: 1,
          carton_id: '00000388080010609160 1ZW3',
          tracking_number: '985X0320377777'
        },
        {
          header: 'P',
          order_id: 2,
          line_item_no: 1,
          carton_id: '00000388080010609573 8985',
          tracking_number: '173761'
        },
        {
          header: 'P',
          order_id: 3,
          line_item_no: 1,
          carton_id: '00000388080010609580 1ZW3',
          tracking_number: '985X0320375555'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 1,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 2,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 3,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 4,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 5,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 6,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 7,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 8,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        },
        {
          header: 'P',
          order_id: 5,
          line_item_no: 9,
          carton_id: '00000388080010608699 1ZW3',
          tracking_number: '985X0320374414'
        }
      ]
    end
  end
end

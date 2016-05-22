class Lsi::AsnReader < Lsi::FixedWidthReader
  add_line_def('$$HDR') do |l|
    l.column(:header, 5)
    l.column(:client_id, 6)
    l.column(:batch_id, 10, :integer)
    l.column(:batch_date_time, 14, :date_time)
  end
  add_line_def('O') do |l|
    l.column(:header,       1)
    l.column(:order_id,    15, :integer)
    l.column(:lsi_order_id, 7, :integer)
    l.column(:shipment_id, 25)
    l.column(:pro_number, 25)
    l.column(:carrier_id, 8)
    l.column(:ship_date, 8, :date)
    l.column(:ship_quantity, 9, :integer)
    l.column(:ship_weight, 7, :decimal)
    l.column(:freight_amount, 9, :decimal)
    l.column(:special_handling, 9, :decimal)
    l.column(:freight_collect, 1)
    l.column(:freight_responsibility, 1)
    l.column(:ref_no, 25)
    l.column(:cancel_reason_code, 2)
    l.column(:reason_code_text, 30)
    l.column(:secondary_po, 24)
    l.column(:ship_from, 20)
    l.column(:scac_code, 4)
  end
  add_line_def('I') do |l|
    l.column(:header, 1)
    l.column(:order_id, 15, :integer)
    l.column(:line_item_no, 5, :integer)
    l.column(:lsi_line_item_no, 5, :integer)
    l.column(:sku_10, 10)
    l.column(:price, 9, :decimal)
    l.column(:shipped_quantity, 9, :integer)
    l.column(:internal_1, 96)
    l.column(:cancel_reason_code, 2)
    l.column(:sku_13, 13)
  end
  add_line_def('P') do |l|
    l.column(:header, 1)
    l.column(:order_id, 15, :integer)
    l.column(:line_item_no, 5, :integer)
    l.column(:carton_id, 25)
    l.column(:tracking_number, 25)
    l.column(:internal_1, 79)
    l.column(:packed_quantity, 9, :integer)
    l.column(:carton_weight, 7, :decimal)
  end
  add_line_def('$$EOF') do |l|
    l.column(:header, 5)
    l.column(:client_id, 6)
    l.column(:batch_id, 10, :integer)
    l.column(:batch_date_time, 14, :date_time)
    l.column(:record_count, 7, :integer)
  end

  protected

  def process_data(data)
    actual_line_count = line_count - 1 # exclude the header
    if data[:header] == '$$EOF' && actual_line_count != data[:record_count]
      Rails.logger.warn "The actual record count (#{actual_line_count}) does not match the reported record count (#{data[:record_count]})"
    end
  end
end

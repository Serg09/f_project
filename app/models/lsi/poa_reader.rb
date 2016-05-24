# Reads purchase order acknowledgment files from LSI
class Lsi::PoaReader < Lsi::FixedWidthReader
  add_line_def('$$HDR') do |line|
    line.column(:header,           5)
    line.column(:client_id,        6)
    line.column(:batch_id,        10, :integer)
    line.column(:batch_date_time, 14, :date_time)
  end
  add_line_def('H1') do |line|
    line.column(:header,     2)
    line.column(:batch_id,  10, :integer)
    line.column(:order_id,  15, :integer)
    line.column(:order_date, 8, :date)
  end
  add_line_def('H2') do |line|
    line.column(:header,    2)
    line.column(:batch_id, 10, :integer)
    line.column(:order_id, 15, :integer)
    line.column(:error,    40)
  end
  add_line_def('D1') do |line|
    line.column(:header,       2)
    line.column(:batch_id,    10, :integer)
    line.column(:order_id,    15, :integer)
    line.column(:line_item_no, 5, :integer)
    line.column(:sku_10,      10)
    line.column(:quantity,     9, :integer)
    line.column(:sku_13,      13)
  end
  add_line_def('D2') do |line|
    line.column(:header,         2)
    line.column(:batch_id,      10, :integer)
    line.column(:order_id,      15, :integer)
    line.column(:line_item_no,   5, :integer)
    line.column(:sku_10,        10)
    line.column(:status_code,    2)
    line.column(:ship_quantity,  9, :integer)
    line.column(:error_message, 40)
    line.column(:sku_13,        13)
  end
  add_line_def('$$EOF') do |line|
    line.column(:header,           5)
    line.column(:client_id,        6)
    line.column(:batch_id,        10, :integer)
    line.column(:batch_date_time, 14, :date_time)
    line.column(:record_count,     7, :integer)
  end

  protected

  def process_data(data)
    actual_line_count = line_count - 1 # exclude the header
    if data[:header] == '$$EOF' && actual_line_count != data[:record_count]
      Rails.logger.warn "The actual record count (#{actual_line_count}) does not match the reported record count (#{data[:record_count]})"
    end
  end
end

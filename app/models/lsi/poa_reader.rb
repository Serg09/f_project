# Reads purchase order acknowledgment files from LSI
class Lsi::PoaReader < Lsi::FixedWidthReader
  BATCH_HEADER = [
    ColumnDef.new(:header,           5),
    ColumnDef.new(:client_id,        6),
    ColumnDef.new(:batch_id,        10, :integer),
    ColumnDef.new(:batch_date_time, 14, :date_time)
  ]
  ORDER_RECORD = [
    ColumnDef.new(:header,     2),
    ColumnDef.new(:batch_id,  10, :integer),
    ColumnDef.new(:order_id,  15, :integer),
    ColumnDef.new(:order_date, 8, :date)
  ]
  ORDER_ERROR = [
    ColumnDef.new(:header,    2),
    ColumnDef.new(:batch_id, 10, :integer),
    ColumnDef.new(:order_id, 15, :integer),
    ColumnDef.new(:error,    40)
  ]
  ITEM_RECORD = [
    ColumnDef.new(:header,       2),
    ColumnDef.new(:batch_id,    10, :integer),
    ColumnDef.new(:order_id,    15, :integer),
    ColumnDef.new(:line_item_no, 5, :integer),
    ColumnDef.new(:sku_10,      10),
    ColumnDef.new(:quantity,     9, :integer),
    ColumnDef.new(:sku_13,      13)
  ]
  ITEM_ERROR = [
    ColumnDef.new(:header,         2),
    ColumnDef.new(:batch_id,      10, :integer),
    ColumnDef.new(:order_id,      15, :integer),
    ColumnDef.new(:line_item_no,   5, :integer),
    ColumnDef.new(:sku_10,        10),
    ColumnDef.new(:status_code,    2),
    ColumnDef.new(:ship_quantity,  9, :integer),
    ColumnDef.new(:error_message, 40),
    ColumnDef.new(:sku_13,        13)
  ]
  BATCH_FOOTER = [
    ColumnDef.new(:header,           5),
    ColumnDef.new(:client_id,        6),
    ColumnDef.new(:batch_id,        10, :integer),
    ColumnDef.new(:batch_date_time, 14, :date_time),
    ColumnDef.new(:record_count,     7, :integer)
  ]

  add_line_def('$$HDR', BATCH_HEADER)
  add_line_def('H1', ORDER_RECORD)
  add_line_def('H2', ORDER_ERROR)
  add_line_def('D1', ITEM_RECORD)
  add_line_def('D2', ITEM_ERROR)
  add_line_def('$$EOF', BATCH_FOOTER)

  protected

  def process_data(data)
    actual_line_count = line_count - 1 # exclude the header
    if data[:header] == '$$EOF' && actual_line_count != data[:record_count]
      Rails.logger.warn "The actual record count (#{actual_line_count}) does not match the reported record count (#{data[:record_count]})"
    end
  end
end

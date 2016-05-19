# Reads purchase order acknowledgment files from LSI
class Lsi::PoaReader < Lsi::FixedWidthReader
  ORDER_RECORD = [
    ColumnDef.new(:header,    2, ->(v){v}),
    ColumnDef.new(:batch_id, 10, ->(v){v.to_i}),
    ColumnDef.new(:order_id, 15, ->(v){v.to_i}),
    ColumnDef.new(:order_date, 8, ->(v){parse_date(v)})
  ]
  ERROR_RECORD = [
    ColumnDef.new(:header,    2, ->(v){v}),
    ColumnDef.new(:batch_id, 10, ->(v){v.to_i}),
    ColumnDef.new(:order_id, 15, ->(v){v.to_i}),
    ColumnDef.new(:error,    40, ->(v){v})
  ]

  add_line_def('H1', ORDER_RECORD, true)
  add_line_def('H2', ERROR_RECORD)

  protected

  def process_line(current_record, data)
    if data[:header] == 'H1'
      current_record[:order_id] = data[:order_id]
      current_record[:batch_id] = data[:batch_id]
      current_record[:order_date] = data[:order_date]
    elsif data[:header] == 'H2'
      errors = current_record[:errors] || []
      errors << data[:error]
      current_record[:errors] = errors
    end
  end
end

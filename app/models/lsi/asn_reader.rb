class Lsi::AsnReader < Lsi::FixedWidthReader
  ORDER_RECORD = [
    ColumnDef.new(:header,       1),
    ColumnDef.new(:order_id,    15, ->(v){v.to_i}),
    ColumnDef.new(:lsi_order_id, 7, ->(v){v.to_i}),
    ColumnDef.new(:shipment_id, 25)
  ]
  ITEM_RECORD = [
  ]
  CARTON_RECORD = [
  ]

  add_line_def('O', ORDER_RECORD, true)

  protected

  def process_line(current_record, data)
    case data[:header]
    when 'O'
      current_record[:order_id] = data[:order_id]
    end
  end
end

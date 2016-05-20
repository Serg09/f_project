class Lsi::AsnReader < Lsi::FixedWidthReader
  BATCH_RECORD = [
    ColumnDef.new(:header, 5),
    ColumnDef.new(:client_id, 6),
    ColumnDef.new(:batch_id, 10, :integer),
    ColumnDef.new(:batch_date_time, 14, :date_time)
  ]
  ORDER_RECORD = [
    ColumnDef.new(:header,       1),
    ColumnDef.new(:order_id,    15, :integer),
    ColumnDef.new(:lsi_order_id, 7, :intger),
    ColumnDef.new(:shipment_id, 25),
    ColumnDef.new(:pro_number, 25),
    ColumnDef.new(:carrier_id, 8),
    ColumnDef.new(:ship_date, 8, :date),
    ColumnDef.new(:ship_quantity, 9, :integer),
    ColumnDef.new(:ship_weight, 7, :decimal),
    ColumnDef.new(:freight_amount, 9, :decimal),
    ColumnDef.new(:special_handling, 9, :decimal),
    ColumnDef.new(:freight_collect, 1),
    ColumnDef.new(:freight_responsibility, 1),
    ColumnDef.new(:ref_no, 25),
    ColumnDef.new(:cancel_reason_code, 2),
    ColumnDef.new(:reason_code_text, 30),
    ColumnDef.new(:secondary_po, 24),
    ColumnDef.new(:ship_from, 20),
    ColumnDef.new(:scac_code, 4)
  ]
  ITEM_RECORD = [
  ]
  CARTON_RECORD = [
  ]

  add_line_def('$$HDR', BATCH_RECORD)
  add_line_def('O', ORDER_RECORD)
end

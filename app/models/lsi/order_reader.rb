# Reads order files
# This is for simulation in the local development
# environment. In production, this would be
# done by LSI
class Lsi::OrderReader < Lsi::FixedWidthReader
  add_line_def('$$HDR') do |line|
    line.column :hreader          , 5
    line.column :client_id        , 6
    line.column :batch_id         , 10
    line.column :batch_date_time  , 14, :date_time
  end
  add_line_def('H1') do |line|
    line.column :header             , 2
    line.column :order_id           , 15  , :integer
    line.column :order_date         , 8   , :date
    line.column :ref_no             , 30
    line.column :order_type         , 1
    line.column :blank_1            , 1
    line.column :customer_order_id  , 25
    line.column :blank_2            , 10
    line.column :lsi_ship_group_code, 8
    line.column :blank_3            , 1
    line.column :blank_4            , 1
    line.column :terms              , 30
    line.column :blank_5            , 57
    line.column :blank_6            , 6
    line.column :blank_7            , 30
    line.column :backorder_qualifier, 2
    line.column :backorder          , 2
    line.column :cancel_backorder_by, 8   , :date
    line.column :currency_code      , 3
    line.column :rush               , 2
    line.column :consolidation_flag , 2
  end

  add_line_def('H2') do |line|
    line.column :header       , 2
    line.column :order_id     , 15, :integer
    line.column :address_type , 2
    line.column :blank_1      , 25
    line.column :customer_name, 35
    line.column :blank_2      , 15
    line.column :line_1       , 35
    line.column :blank_3      , 15
    line.column :line_2       , 35
    line.column :blank_4      , 15
    line.column :line_3       , 35
    line.column :blank_5      , 65
    line.column :city         , 30
    line.column :state        , 2
    line.column :postal_code  , 9
    line.column :country_code , 3
    line.column :telephone    , 15
    line.column :blank_6      , 5
  end

  add_line_def('H3') do |line|
    line.column :header       , 2
    line.column :order_id     , 15, :integer
    line.column :note_text    , 70
    line.column :note_type    , 3
  end

  add_line_def('D1') do |line|
    line.column :header             , 2
    line.column :order_id           , 15  , :integer
    line.column :customer_order_id  , 25
    line.column :line_item_no       , 5   , :integer
    line.column :blank_1            , 3
    line.column :blank_2            , 8
    line.column :sku                , 10
    line.column :blank_3            , 78
    line.column :quantity           , 7   , :integer
    line.column :blank_4            , 21
    line.column :blank_5            , 1
    line.column :unit_price         , 9   , :decimal
    line.column :blank_6            , 1
    line.column :discount_percent   , 5   , :decimal
    line.column :blank_7            , 7
    line.column :freight            , 9   , :decimal
    line.column :blank_8            , 1
    line.column :tax                , 9   , :decimal
    line.column :blank_9            , 1
    line.column :handling           , 9   , :decimal
    line.column :sku_13             , 13
    line.column :blank_10           , 7
    line.column :sku_14             , 14
    line.column :blank_11           , 6
  end

  add_line_def('D3') do |line|
    line.column :header             , 2
    line.column :order_id           , 15  , :integer
    line.column :line_item_no       , 5   , :integer
    line.column :quantity           , 9   , :integer
    line.column :blank_1            , 9
    line.column :schedule_b         , 15
    line.column :description        , 30
    line.column :country_of_origin  , 3
  end

  add_line_def('$$OEF') do |line|
    line.column :header             , 5
    line.column :client_id          , 6
    line.column :batch_id           , 10  , :integer
    line.column :batch_date_time    , 14  , :date_time
    line.column :record_count       , 7   , :integer
  end
end

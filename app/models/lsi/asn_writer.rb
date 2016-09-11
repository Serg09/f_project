module Lsi
  # Writes Advanced Shipping Notifications
  #
  # This is the simulate LSI behaviors in development
  class AsnWriter
    include FixedWidthWriterHelpers

    @queue = :normal

    def self.perform(order)
      new(order.with_indifferent_access).perform
    end

    @@files = Hash.new{|h, k| h[k] = 0}
    def self.file_name
      date_part = DateTime.now.strftime('%m%d%M')
      index = @@files[date_part] += 1
      "M#{date_part}#{index}.PBS"
    end

    def initialize(order)
      @order = order
    end

    def logger
      @logger ||= Logger.new(STDOUT) #Rails.logger
    end

    def perform
      file_name = AsnWriter.file_name
      logger.debug "Write simulated shipping notification for order #{@order[:order_id]} to #{file_name}"
      REMOTE_FILE_PROVIDER.send_file asn_file, file_name, 'outgoing'
    end

    def asn_file
      f = StringIO.new
      write_batch_header f
      write_order_header f
      record_count = 1
      @order[:items].each do |i|
        write_item f, i
        write_carton f, i
        record_count += 1
      end
      write_batch_trailer f, record_count
      f.rewind
      f
    end

    def item_quantity
      @order[:items].reduce(0) do |sum, item|
        sum + item[:quantity]
      end
    end

    def item_weight
      15.5
    end

    def freight_amount
      23.45
    end

    def special_handling
      1.65
    end

    def lsi_order_number
      rand(100000..999999)
    end

    def shipment_id
      SecureRandom.uuid
    end

    def pro_number
      rand(100..999).to_s
    end

    def carrier_id
      'UPSNDA'
    end

    def ship_date
      DateTime.now
    end

    def ship_from
      '1796976'
    end

    def ucc(item)
      ''
    end

    def tracking_number(item)
      SecureRandom.uuid
    end

    def carton_weight(item)
      rand(1000..2000) / 100
    end

    def write_batch_header(f)
      f.print '$$HDR'
      f.print number_of_length(LSI_CLIENT_ID, 6)
      f.print number_of_length(@order[:batch_id], 10)
      f.print @order[:batch_date_time].strftime('%Y%m%d')
      f.print @order[:batch_date_time].strftime('%H%M%S')
      f.puts ''
    end

    def write_batch_trailer(f, record_count)
      f.print '$$OEF'
      f.print number_of_length(LSI_CLIENT_ID, 6)
      f.print number_of_length(@order[:batch_id], 10)
      f.print @order[:batch_date_time].strftime('%Y%m%d')
      f.print @order[:batch_date_time].strftime('%H%M%S')
      f.print number_of_length(record_count, 7)
      f.puts ''
    end

    def write_order_header(f)
      f.print 'O'
      f.print alpha_of_length @order[:order_id], 15
      f.print number_of_length lsi_order_number, 7
      f.print alpha_of_length shipment_id, 25
      f.print alpha_of_length pro_number, 25
      f.print alpha_of_length carrier_id, 8
      f.print ship_date.strftime('%Y%m%d')
      f.print number_of_length item_quantity, 9
      f.print number_of_length item_weight, 7, 2
      f.print number_of_length freight_amount, 9, 2
      f.print number_of_length special_handling, 9, 2
      f.print 'N', 1 # freight collect flag
      f.print 'P', 1 # freight responsibility
      f.print blank_of_length 25 #ref no
      f.print blank_of_length 2 # cancel reason code
      f.print blank_of_length 30 # cancel reason text
      f.print alpha_of_length @order[:customer_order_id], 25
      f.print alpha_of_length ship_from, 20
      f.print blank_of_length 4
      f.puts ''
    end

    def write_item(f, item)
      f.print 'I'
      f.print alpha_of_length @order[:order_id], 15
      f.print number_of_length item[:line_item_no], 5
      f.print number_of_length item[:line_item_no], 5
      f.print alpha_of_length item[:sku].length <= 10 ? item[:sku] : nil, 10
      f.print number_of_length item[:unit_price], 9, 2
      f.print number_of_length item[:quantity], 9
      f.print blank_of_length 96 # internal use
      f.print blank_of_length 2  # cancel reason code
      f.print blank_of_length 30 # cancel reason text
      f.print alpha_of_length item[:sku].length == 13 ? item[:sku] : nil, 13
      f.print blank_of_length 36 # internal use
      f.puts ''
    end

    def write_carton(f, item)
      f.print 'P'
      f.print alpha_of_length @order[:order_id], 15
      f.print number_of_length item[:line_item_no], 5
      f.print alpha_of_length ucc(item), 25
      f.print alpha_of_length tracking_number(item), 25
      f.print blank_of_length 79 # internal use
      f.print number_of_length item[:quantity], 9
      f.print number_of_length carton_weight(item), 7, 2
      f.puts ''
    end
  end
end

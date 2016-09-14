module Lsi
  # Writes Purchase order acknowledgements
  #
  # This is to simulate LSI behaviors for development purposes
  class PoaWriter
    include FixedWidthWriterHelpers

    @queue = :normal

    def self.perform(order)
      new(order.with_indifferent_access).perform
    end

    @@files = Hash.new{|h, k| h[k] = 0}
    def self.file_name
      date_part = DateTime.now.strftime('%m%d%M')
      index = @@files[date_part] += 1
      "M#{date_part}#{index}.PPR"
    end

    def initialize(order)
      @order = order
    end

    def logger
      @logger ||= Logger.new(STDOUT) #Rails.logger
    end

    def perform
      logger.debug "start Lsi::PoaWriter#perform"
      file_name = PoaWriter.file_name
      logger.debug "Write simulated acknowledgement for order #{@order[:order_id]} to #{file_name}"
      REMOTE_FILE_PROVIDER.send_file poa_file, file_name, 'outgoing'
      logger.debug "end Lsi::PoaWriter#perform"
    rescue => e
      logger.error "Error writing POA file: #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end

    def poa_file
      f = StringIO.new
      write_batch_header f
      write_order_header f
      record_count = 1
      @order[:items].each do |i|
        write_item f, i
        record_count += 1
      end
      write_batch_trailer f, record_count
      f.rewind
      f
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
      f.print '$$EOF'
      f.print number_of_length(LSI_CLIENT_ID, 6)
      f.print number_of_length(@order[:batch_id], 10)
      f.print @order[:batch_date_time].strftime('%Y%m%d')
      f.print @order[:batch_date_time].strftime('%H%M%S')
      f.print number_of_length(record_count, 7)
      f.puts ''
    end

    def write_order_header(f)
      f.print 'H1'
      f.print number_of_length @order[:batch_id], 10
      f.print alpha_of_length @order[:order_id], 15
      f.print @order[:order_date].strftime('%Y%m%d')
      f.print @order[:order_date].strftime('%H%M%S')
      f.print blank_of_length 165
      f.puts ''
    end

    def write_item(f, item)
      f.print 'D1'
      f.print number_of_length @order[:batch_id], 10
      f.print alpha_of_length @order[:order_id], 15
      f.print number_of_length item[:line_item_no], 5
      f.print alpha_of_length (item[:sku].length <= 10 ? item[:sku] : nil), 10
      f.print number_of_length item[:quantity], 9
      f.print alpha_of_length (item[:sku].length == 13 ? item[:sku] : nil), 13
      f.print blank_of_length 135
      f.puts ''

      f.print 'D2'
      f.print number_of_length @order[:batch_id], 10
      f.print alpha_of_length @order[:order_id], 15
      f.print number_of_length item[:line_item_no], 5
      f.print alpha_of_length (item[:sku].length <= 10 ? item[:sku] : nil), 10
      f.print alpha_of_length 'AR', 2
      f.print number_of_length item[:quantity], 9
      f.print blank_of_length 40
      f.print alpha_of_length (item[:sku].length == 13 ? item[:sku] : nil), 13
      f.print blank_of_length 93
      f.puts
    end
  end
end

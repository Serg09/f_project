module Lsi
  # Writes Advanced Shipping Notifications
  #
  # This is the simulate LSI behaviors in development
  class AsnWriter
    include FixedWidthWriterHelpers

    @queue = :normal

    def self.perform
      new(params[:order]).perform
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

    def perform
      REMOTE_FILE_PROVIDER.send_file asn_file, AsnWriter.file_name, 'outgoing'
    end

    def asn_file
      f = StringIO.new
      write_batch_header f
      write_order_header f
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

    def write_batch_header(f)
      f.print '$$HDR'
      f.print number_of_length(LSI_CLIENT_ID, 6)
      f.print number_of_length(@order[:batch_id], 10)
      f.print @order[:batch_date_time].strftime('%Y%m%d')
      f.print @order[:batch_date_time].strftime('%H%M%S')
      f.puts ''
    end

    def write_order_header(f)
      f.print 'O'
      f.print number_of_length(@order[:order_id], 15)
      f.print number_of_length(9999, 7) # LSI order number
      f.print alpha_of_length(SecureRandom.uuid, 25) # shipment ID
      f.print alpha_of_length('?', 25) # PRO Number if Bill of Lading
      f.print alpha_of_length('UPSNDA', 8) # carrier
      f.print DateTime.now.strftime('%Y%m%d') # ship date
      f.print number_of_length(item_quantity, 9)
      f.print number_of_length(item_weight, 7, 2)
      f.print number_of_length(freight_amount, 9, 2)
    end
  end
end

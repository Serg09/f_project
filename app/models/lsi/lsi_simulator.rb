module Lsi
  class LsiSimulator
    @queue = :normal

    def self.perform
      new.perform
    end

    def logger
      @logger ||= Logger.new(STDOUT) #Rails.logger
    end

    def perform
      logger.debug "start Lsi::LsiSimulator#perform"

      REMOTE_FILE_PROVIDER.get_and_delete_files('incoming') do |content, filename|
        logger.debug "simulating acknowledgement for #{filename}"
        process_file(content)
      end

      logger.debug "end Lsi::LsiSimulator#perform"
    end

    private

    def process_file(content)
      OrderTranslator.translate(content).each do |order|
        Resque.enqueue_in 1.minutes, Lsi::PoaWriter, order
        logger.debug "enqueued Lsi::PoaWriter for #{order[:order_id]}"
        Resque.enqueue_in 3.minutes, Lsi::AsnWriter, order
        logger.debug "enqueued Lsi::AsnWriter for #{order[:order_id]}"
      end
    end
  end

  class OrderTranslator
    ADDRESS_TYPE_MAP = {
      'ST' => :shipping,
      'RT' => :return,
      'CS' => :consolidator
    }
    def self.translate(file_content)
      new(file_content).translate
    end

    def initialize(file_content)
      @order = nil
      @reader = OrderReader.
        new(file_content).
        read.
        reduce([]) do |orders, record|
          case record[:header]
          when '$$HDR'
            logger.debug "start reading batch #{record[:batch_id]} from purchase order file"
          when 'H1'
            @order = record
            orders << @order
          when 'H2' # address
            @order[ADDRESS_TYPE_MAP[record[:address_type]]] = record
          when 'H3'
            @order[:notes] = [] unless @order[:notes]
            @order[:notes] << record
          when 'D1'
            @order[:items] = [] unless @order[:items]
            @order[:items] << record
          when 'D3'
            item = @order[:items].detect{|i| i[:line_item_no] == record[:line_item_no]}
            [:schedule_b, :description, :country_of_origin].each do |key|
              item[key] = record[key]
            end
          when '$$OEF'
            logger.debug "end reading batch #{record[:batch_id]} from purchase order file"
          end
          orders
        end
    end

    def translate
      @reader
    end
  end
end

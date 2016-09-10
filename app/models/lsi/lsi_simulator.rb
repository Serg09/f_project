module Lsi
  class PoaSimulator
    @queue = :normal

    def self.perform
      new.perform
    end

    def perform
      REMOTE_FILE_PROVIDER.get_and_delete_files('incoming') do |content, filename|
        Rails.logger.info "simulating acknowledgement for #{filename}"
        process_file(content)
      end
    end

    private

    def process_file(content)
      OrderTranslator.translate(content).each do |order|
        Resque.enqueue_in 2.minutes, PoaWriter, order
        Resque.enqueue_in 5.minutes, AsnWriter, order
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
            Rails.logger.debug "reading order #{record[:order_id]} from purchase order file"
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
          end
          orders
        end
    end

    def translate
      @reader
    end
  end
end

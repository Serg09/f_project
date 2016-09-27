module Lsi
  class LsiSimulator
    include LogHelper

    @queue = :normal

    def self.perform
      new.perform
    end

    def perform
      logger.debug "start Lsi::LsiSimulator#perform"
      REMOTE_FILE_PROVIDER.get_and_delete_files('incoming') do |content, filename|
        logger.debug "simulating acknowledgement for #{filename}"
        process_file(content)
      end
      logger.debug "end Lsi::LsiSimulator#perform"
    rescue => e
      logger.error "Error simulating LSI ingestion. #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end

    private

    def process_file(content)
      batch = OrderTranslator.translate(content)
      logger.debug "enqueue PoaWriter for batch #{batch[:batch_id]}"
      Resque.enqueue_in 1.minutes, Lsi::PoaWriter, batch
      logger.debug "enqueue AsnWriter for order #{batch[:batch_id]}"
      Resque.enqueue_in 3.minutes, Lsi::AsnWriter, batch
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
      @file_content = file_content
    end

    def translate
      order = nil
      OrderReader.
        new(@file_content).
        read.
        reduce({}) do |batch, record|
          case record[:header]
          when '$$HDR'
            logger.debug "start reading batch #{record[:batch_id]} from purchase order file"
            batch[:client_id] = record[:client_id]
            batch[:batch_id] = record[:batch_id]
            batch[:batch_date_time] = record[:batch_date_time]
            batch[:orders] = []
          when 'H1'
            order = record
            batch[:orders] << order
          when 'H2' # address
            order[ADDRESS_TYPE_MAP[record[:address_type]]] = record
          when 'H3'
            order[:notes] = [] unless order[:notes]
            order[:notes] << record
          when 'D1'
            order[:items] = [] unless order[:items]
            order[:items] << record
          when 'D3'
            item = order[:items].detect{|i| i[:line_item_no] == record[:line_item_no]}
            [:schedule_b, :description, :country_of_origin].each do |key|
              item[key] = record[key]
            end
          when '$$OEF'
            logger.debug "end reading batch #{record[:batch_id]} from purchase order file"
          end
          batch
        end
    end
  end
end

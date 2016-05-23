module Lsi
  class AsnProcessor
    def initialize(content)
      @content = content
    end

    def process
      reader = Lsi::AsnReader.new(@content)
      reader.read.reduce(true){|result, r| process_record(r) && result}
    end

    private

    def process_record(record)
      order = Order.find(record[:order_id]) if record[:order_id]
      case record[:header]
      when '$$HDR'
        Rails.logger.info "Processing advanced shipping notification for batch #{record[:batch_id]}"
        true
      when 'O'
        process_order(record, order)
      when 'I'
        process_item(record, order)
      when 'P'
        process_package(record, order)
      else
        true
      end
    rescue => e
      Rails.logger.error "Error processing record #{record.inspect} #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end

    def process_order(record, order)
    end

    def process_item(record, order)
    end

    def process_package(record, order)
    end
  end
end

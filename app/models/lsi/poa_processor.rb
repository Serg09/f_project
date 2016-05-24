module Lsi
  class PoaProcessor
    def initialize(content)
      @content = content
    end

    def process
      reader = Lsi::PoaReader.new(@content)
      reader.read.reduce(true){|result, r| process_record(r) && result}
    end

    private

    def process_record(record)
      order = Order.find(record[:order_id]) if record[:order_id]
      case record[:header]
      when '$$HDR'
        Rails.logger.info "Processing order acknowledgment batch #{record[:batch_id]}"
        true
      when 'H1'
        process_order(record, order)
      when 'H2'
        process_order_error(record, order)
      when 'D2'
        process_item(record, order)
      else
        true
      end
    rescue => e
      Rails.logger.error "Unable to process POA record #{record.inspect} #{e.class.name} - #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end

    def process_order(record, order)
      order.acknowledge!
    end

    def process_order_error(record, order)
      if order.error.present?
        order.error << "\n#{record[:error]}"
      else
        order.error = record[:error]
      end
      order.reject!
    end

    def process_item(record, order)
      item = order.items.find_by(line_item_no: record[:line_item_no])
      sku = record[:sku_13] || record[:sku_10]
      if sku == item.sku
        case record[:status_code]
        when 'AR'
          item.accepted_quantity = record[:ship_quantity]
          item.acknowledge!
        when 'CO'
          item.cancel!
        when 'IR'
          item.reject!
        when 'BO'
          item.back_order!
        end
      else
        Rails.logger.warn "Unable to update order item #{item.id} because sku #{item.sku} does not match the specified sku #{sku}."
      end
    end
  end
end

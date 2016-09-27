module Lsi
  class AsnProcessor
    include LogHelper

    def initialize(content)
      @content = content
    end

    def process
      reader = Lsi::AsnReader.new(@content)
      reader.read.reduce(true){|result, r| process_record(r) && result}
    end

    private

    def process_record(record)
      @order = Order.find(record[:order_id]) if record[:order_id]
      case record[:header]
      when '$$HDR'
        logger.info "Processing advanced shipping notification for batch #{record[:batch_id]}"
        true
      when 'O'
        process_order(record)
      when 'I'
        process_item(record)
      when 'P'
        process_package(record)
      else
        true
      end
    rescue => e
      logger.error "Error processing record #{record.inspect} #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end

    def process_order(record)
      @shipment = @order.shipments.create! external_id: record[:shipment_id],
                                           ship_date: record[:ship_date],
                                           quantity: record[:ship_quantity],
                                           weight: record[:weight],
                                           freight_charge: record[:freight_charge],
                                           handling_charge: record[:handling_charge],
                                           collect_freight: record[:collect_freight] == 'Y',
                                           freight_responsibility: record[:freight_responsibility] == 'C' ? 'customer' : 'publisher',
                                           cancel_code: record[:cancel_code],
                                           cancel_reason: record[:cancel_reason]
      logger.info "created shipment #{@shipment.id}"
    end

    def process_item(record)
      order_item = @order.items.find_by(line_item_no: record[:line_item_no])
      if order_item
        @shipment_item = @shipment.items.create! order_item: order_item,
                                                external_line_no: record[:lsi_line_item_no],
                                                sku: record[:sku_10] || record[:sku_13],
                                                unit_price: record[:price],
                                                shipped_quantity: record[:shipped_quantity],
                                                cancel_code: record[:cancel_code],
                                                cancel_reason: record[:cancel_reason]
        logger.info "created shipment item #{@shipment_item.id}"
        if order_item.all_items_shipped?
          order_item.ship!
          logger.info "marked item #{order_item.id} as shipped"
          if @order.all_items_shipped?
            @order.ship!
            logger.info "marked order #{@order.id} as shipped"
          end
        elsif order_item.some_items_shipped?
          order_item.ship_part!
          logger.info "marked item #{order_item.id} as partially shipped"
        end
      else
        logger.warn "Unable to process shipment item: order item not found: #{record.inspect}"
      end
    end

    def process_package(record)
      @shipment_item.packages.create! package_id: record[:carton_id],
                                      tracking_number: record[:tracking_number],
                                      quantity: record[:packed_quantity],
                                      weight: record[:carton_weight]
    end
  end
end

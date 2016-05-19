class UpdateImportProcessor
  @queue = :normal

  def self.perform
    Rails.logger.debug "start UpdateImportProcessor::perform"

    REMOTE_FILE_PROVIDER.get_and_delete_files('outgoing') do |file, filename|
      Rails.logger.info "importing file #{filename}"
      Document.create source: 'lsi', filename: filename, content: file
      process_file file
    end

    Rails.logger.debug "end UpdateImportProcessor::perform"
  end

  private

  # processes the file
  #
  # return true to indicate the remote file should be deleted
  def self.process_file(file)
    reader = Lsi::PoaReader.new(file)
    reader.read.reduce(true){|result, r| process_record(r) && result}
  end

  def self.process_record(record)
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

  def self.process_order(record, order)
    order.acknowledge!
  end

  def self.process_order_error(record, order)
    order = Order.find(record[:order_id])
    if order.error
      order.error = record[:error]
    else
      order.error << "\n#{record[:error]}"
    end
    order.reject!
  end

  def self.process_item(record, order)
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

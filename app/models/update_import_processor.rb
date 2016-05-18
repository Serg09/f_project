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

    Rails.logger.info "processing order #{record[:order_id]}"

    order = Order.find(record[:order_id])
    if record[:errors].present?
      order.error = record[:errors].join("\n")
      order.reject!
    else
      order.acknowledge!
    end
  rescue => e
    Rails.logger.error "Unable to process POA record #{record.inspect} #{e.class.name} - #{e.message}\n  #{e.backtrace.join("\n  ")}"
  end
end

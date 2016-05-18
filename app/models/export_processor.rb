class ExportProcessor
  @queue = :normal

  def self.perform(options = {})
    Rails.logger.debug "start ExportProcessor::perform"

    batches = if options['retry']
                Batch.by_status('new')
              else
                [Batch.batch_orders].compact
              end
    if batches.any?
      batches.each do |batch|
        file = create_batch_file(batch)
        send_file(file)
        batch.update_attribute :status, Batch.DELIVERED
        batch.orders.each{|o| o.export!}
      end
    else
      Rails.logger.info "No orders to export"
    end

    Rails.logger.debug "end ExportProcessor::perform"
  rescue => e
    Rails.logger.error "Unable to complete the export. batches=#{batches.inspect} error: #{e.class.name} : #{e.message}\n  #{e.backtrace.join("\n  ")}"
  end

  private

  def self.create_batch_file(batch)
    writer = Lsi::BatchWriter.new(batch)
    file = StringIO.new
    writer.write file
    file.rewind
    file
  end

  def self.remote_file_name
    "PPO.M#{DateTime.now.utc.strftime('%m%d%H%M')}"
  end

  def self.send_file(file)
    REMOTE_FILE_PROVIDER.send_file(file, remote_file_name, 'incoming')
  end
end

class ExportProcessor
  @queue = :normal

  def self.perform
    Rails.logger.info "start ExportProcessor::perform"

    batch = Batch.batch_orders
    if batch
      file = create_batch_file(batch)
      send_file(file)
      batch.update_attribute :status, Batch.DELIVERED
    else
      Rails.logger.info "end ExportProcessor::perfom - no orders to export"
    end
  rescue => e
    Rails.logger.error "Unable to complete the export. batch=#{batch.try(:inspect)} error: #{e.class.name} : #{e.message}\n  #{e.backtrace.join("\n  ")}"
  end

  private

  def self.create_batch_file(batch)
    writer = LsiBatchWriter.new(batch)
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

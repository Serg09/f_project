class OrderImportProcessor
  @queue = :normal

  def self.perform
    Rails.logger.debug "start OrderImportProcessor::perform"
    Client.order_importers.each do |client|
      folder = client.abbreviation
      Rails.logger.debug "import orders from #{client.name} (#{folder})"
      ORDER_IMPORT_FILE_PROVIDER.get_and_delete_files(folder) do |content, filename|
        Rails.logger.info "importing order file #{filename}"
        begin
          client.import_orders(content)
        rescue => e
          Rails.logger.error "Error importing order #{filename} in folder #{folder}. #{e.class.name} #{e.message}\n  #{e.backtrace.join("\n  ")}"
        end
        Document.create source: '3DM', filename: filename, content: content
      end
    end

    Rails.logger.debug "end OrderImportProcessor::perform"
  end
end

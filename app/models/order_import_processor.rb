class OrderImportProcessor
  @queue = :normal

  PROCESSOR_MAP = {
    '3dm' => ThreeDM::OrderImporter
  }

  def self.perform
    Rails.logger.debug "start OrderImportProcessor::perform"
    PROCESSOR_MAP.each do |folder, processor_class|
      ORDER_IMPORT_FILE_PROVIDER.get_and_delete_files(folder) do |content, filename|
        Rails.logger.info "importing order file #{filename}"
        begin
          processor_class.new(content).process
        rescue => e
          Rails.logger.error "Error importing order #{filename} in folder #{folder}. #{e.class.name} #{e.message}\n  #{e.backtrace.join("\n  ")}"
        end
        Document.create source: '3DM', filename: filename, content: content
      end
    end

    Rails.logger.debug "end OrderImportProcessor::perform"
  end
end

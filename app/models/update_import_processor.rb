class UpdateImportProcessor
  @queue = :normal

  PROCESSOR_MAP = {
    '.PPR' => Lsi::PoaProcessor,
    '.PBS' => Lsi::AsnProcessor
  }

  def self.perform
    Rails.logger.debug "start UpdateImportProcessor::perform"

    REMOTE_FILE_PROVIDER.get_and_delete_files('outgoing') do |file, filename|
      Rails.logger.info "importing file #{filename}"
      processor(file, filename).process
      Document.create source: 'lsi', filename: filename, content: file
    end

    Rails.logger.debug "end UpdateImportProcessor::perform"
  end

  private

  def self.processor(file, filename)
    ext = File.extname(filename)
    processor_class = PROCESSOR_MAP[ext]
    raise "Unrecognized file extension \"#{ext}\"." unless processor_class
    processor = processor_class.new(file)
  end
end

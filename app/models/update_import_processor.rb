class UpdateImportProcessor
  include LogHelper

  @queue = :normal

  PROCESSOR_MAP = {
    '.PPR' => Lsi::PoaProcessor,
    '.PBS' => Lsi::AsnProcessor
  }

  def self.perform
    new.perform
  end

  def perform
    logger.debug "start UpdateImportProcessor#perform"

    REMOTE_FILE_PROVIDER.get_and_delete_files('outgoing') do |file, filename|
      logger.info "importing file #{filename}"
      processor(file, filename).process
      Document.create source: 'lsi', filename: filename, content: file
    end

    logger.debug "end UpdateImportProcessor#perform"
    true
  rescue => e
    logger.error "Error importing order updates. #{e.class.name} #{e.message}\n  #{e.backtrace.join("\n  ")}"
    false
  end

  private

  def processor(file, filename)
    ext = File.extname(filename)
    processor_class = PROCESSOR_MAP[ext]
    raise "Unrecognized file extension \"#{ext}\"." unless processor_class
    logger.info "processing file #{file} with #{processor_class.name}"
    processor = processor_class.new(file)
  end
end

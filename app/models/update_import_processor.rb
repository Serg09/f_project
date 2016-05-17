class UpdateImportProcessor
  def self.perform
    REMOTE_FILE_PROVIDER.get_and_delete_files('outgoing') do |file|
      process_file file
    end
  end

  private

  # processes the file
  #
  # return true to indicate the remote file should be deleted
  def self.process_file(file)
    true
  end
end

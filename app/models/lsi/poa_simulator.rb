module Lsi
  class PoaSimulator
    @queue = :normal

    def self.perform
      new.perform
    end

    def perform
      REMOTE_FILE_PROVIDER.get_and_delete_files('incoming') do |content, filename|
        Rails.logger.info "simulating acknowledgement for #{filename}"
        OrderReader.new(content)
      end
    end
  end
end

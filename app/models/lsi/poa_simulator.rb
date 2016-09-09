module Lsi
  class PoaSimulator
    @queue = :normal

    def self.perform
      new.perform
    end

    def perform
      REMOTE_FILE_PROVIDER.get_and_delete_files('incoming') do |content, filename|
        Rails.logger.info "simulating acknowledgement for #{filename}"
        process_file(content)
      end
    end

    private

    def process_file(content)
      OrderTranslator.translate(content).each do |order|
        Resque.enqueue_in 2.minutes, PoaWriter, order
        Resque.enqueue_in 5.minutes, AsnWriter, order
      end
    end

    class OrderTranslator
      def self.translate(file_content)
        new(file_content).translate
      end

      def initialize(file_content)
        @reader = OrderReader.new(file_content)
      end

      def translate
        raise 'Not implemented'
      end
    end

    class PoaWriter
    end

    class AsnWriter
    end
  end
end

namespace :lsi do
  desc 'Export orders to LSI'
  task export: :environment do
    Resque.enqueue ExportProcessor
  end

  desc 'Re-exports new batches'
  task retry: :environment do
    Resque.enqueue ExportProcessor, {retry: true}
  end
end

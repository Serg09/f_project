namespace :lsi do
  desc 'Export orders to LSI'
  task export: :environment do
    Resque.enqueue ExportProcessor
  end
end

namespace :order do
  desc 'Export orders (options: RETRY=true to use existing "new" batches)'
  task export: :environment do
    ExportProcessor.perform retry: ENV['RETRY'].present?
  end

  desc 'Import orders'
  task import: :environment do
    OrderImportProcessor.perform
  end
end

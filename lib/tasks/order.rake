namespace :order do
  desc 'Import orders'
  task import: :environment do
    OrderImportProcessor.perform
  end
end

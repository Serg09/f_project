namespace :order do
  desc 'Export orders (options: RETRY=true to use existing "new" batches)'
  task export: :environment do
    ExportProcessor.perform retry: ENV['RETRY'].present?
  end

  desc 'Import orders'
  task import: :environment do
    OrderImportProcessor.perform
  end

  desc 'Import order status updates from the fulfillment provider'
  task import_updates: :environment do
    UpdateImportProcessor.perform
  end

  if Rails.env.development?
    desc 'Create a sample order'
    task create: :environment do
      client = Client.first || FactoryGirl.create(:client)
      product = Product.first || FactoryGirl.create(:product)
      order = FactoryGirl.create :submitted_order, client: client,
                                                   items: [
                                                     {
                                                       sku: product.sku,
                                                       quantity: rand(1..5)
                                                     }
                                                   ]
      puts "created order:"
      puts JSON.pretty_generate order.as_json(include: [:items])
    end

    desc 'Simulate LSI processing'
    task simulate_lsi: :environment do
      Lsi::LsiSimulator.perform
    end
  end
end

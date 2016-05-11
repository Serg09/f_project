namespace :seed do
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  desc 'Create a certain amount of orders. (COUNT=10)'
  task orders: :environment do
    count = (ENV['COUNT'] || 10).to_i
    (0..count).each do |n|
      o = FactoryGirl.create(:order)
      FactoryGirl.create(:order_item, order: o)
      logger.debug "Created order #{o.inspect}"
    end
  end
end

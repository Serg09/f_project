class Batch < ActiveRecord::Base
  STATUSES = %w(new delivered acknowledged)

  class << self
    STATUSES.each do |status|
      define_method status.upcase do
        status
      end
    end
  end

  has_many :orders

  validates_inclusion_of :status, in: STATUSES

  def self.batch_orders
    return nil unless Order.unbatched.any?

    batch = Batch.create!
    Order.unbatched.each{|o| batch.orders << o}
    batch
  end
end

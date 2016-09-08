# == Schema Information
#
# Table name: batches
#
#  id         :integer          not null, primary key
#  status     :string           default("new"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Batch < ActiveRecord::Base
  STATUSES = %w(new delivered)

  class << self
    STATUSES.each do |status|
      define_method status.upcase do
        status
      end
    end
  end

  has_many :orders

  validates_inclusion_of :status, in: STATUSES

  scope :by_status, ->(status){where(status: status)}

  def self.batch_orders
    return nil unless Order.ready_for_export.any?

    Batch.create!.tap do |b|
      Order.ready_for_export.each{|o| b.orders << o}
    end
  end

  def self.batch_order(order_id)
    Batch.create!.tap do |b|
      b.orders << Order.find(order_id)
    end
  end
end

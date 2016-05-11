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
end

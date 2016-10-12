class Payment < ActiveRecord::Base
  validates_presence_of :order_id, :amount
  validates_numericality_of :amount, greater_than: 0, if: :amount
  validates_length_of :external_id, maximum: 100
end

class OrderItem < ActiveRecord::Base
  belongs_to :order

  before_create :set_line_item_number

  validates_presence_of :order_id,
                        :sku,
                        :quantity

  validates_length_of :sku, maximum: 30
  validates_length_of :description, maximum: 50

  validates_uniqueness_of :sku, scope: :order_id

  validates_numericality_of :quantity, greater_than: 0, on: :create
  validates_numericality_of :quantity, greater_than: -1, on: :update
  validates_numericality_of [:price,
                             :discount_percentage,
                             :freight_charge,
                             :tax], greater_than_or_equal_to: 0

  private

  def set_line_item_number
    self.line_item_no = order.items.count + 1
  end
end

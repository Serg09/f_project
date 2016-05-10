# == Schema Information
#
# Table name: order_items
#
#  id                  :integer          not null, primary key
#  order_id            :integer          not null
#  line_item_no        :integer          not null
#  sku                 :string(30)       not null
#  description         :string(50)
#  quantity            :integer          not null
#  price               :decimal(, )
#  discount_percentage :decimal(, )
#  freight_charge      :decimal(, )
#  tax                 :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

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

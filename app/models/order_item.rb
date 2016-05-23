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
#  status              :string(30)       default("new"), not null
#  accepted_quantity   :integer
#  shipped_quantity    :integer
#

class OrderItem < ActiveRecord::Base
  include AASM

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

  before_validation :set_defaults

  aasm(:status, whiny_transitions: false) do
    state :new, initial: true
    state :processing, :partially_shipped, :shipped, :rejected, :back_ordered, :cancelled

    event :acknowledge do
      transitions from: :new, to: :processing
    end

    event :ship_part do
      transitions from: :processing, to: :partially_shipped
    end

    event :ship do
      transitions from: [:processing, :partially_shipped], to: :shipped
    end

    event :reject do
      before{ self.accepted_quantity = 0 }
      transitions from: :new, to: :rejected
    end

    event :cancel do
      before{ self.accepted_quantity = 0 }
      transitions from: :new, to: :cancelled
    end

    event :back_order do
      transitions from: :new, to: :back_ordered
    end
  end

  def total
    return 0 unless quantity.present? && quantity > 0

    ((price || 0) * quantity) +
      (freight_charge || 0) +
      (tax || 0)
  end

  private

  def set_defaults
    self.discount_percentage = 0 unless discount_percentage
    self.freight_charge = 0 unless freight_charge
    self.tax = 0 unless tax
  end

  def set_line_item_number
    self.line_item_no = order.items.count + 1
  end
end

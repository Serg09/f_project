# == Schema Information
#
# Table name: orders
#
#  id                  :integer          not null, primary key
#  customer_name       :string(50)
#  telephone           :string(25)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  order_date          :date             not null
#  batch_id            :integer
#  status              :string(30)       default("incipient"), not null
#  error               :text
#  client_id           :integer          not null
#  client_order_id     :string(100)
#  customer_email      :string(100)
#  ship_method_id      :integer
#  shipping_address_id :integer
#  confirmation        :string(32)
#

require 'securerandom'

class Order < ActiveRecord::Base
  include AASM

  has_many :items, class_name: 'OrderItem'
  has_many :shipments
  has_many :payments
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :batch
  belongs_to :client
  belongs_to :ship_method

  validates_presence_of :client_id,
                        :order_date
  validates_length_of :customer_name,
                       maximum: 50
  validates_length_of [:client_order_id,
                       :customer_email],
                       maximum: 100
  validates_length_of :telephone, maximum: 25
  validates_uniqueness_of :client_order_id, if: :client_order_id

  accepts_nested_attributes_for :shipping_address

  scope :by_order_date, ->{order('order_date desc')}
  scope :by_status, ->(status){where(status: status)}
  scope :unbatched, ->{where(batch_id: nil)}
  scope :ready_for_export, ->{unbatched.where(status: :submitted)}

  STATUSES = [:incipient, :submitted, :exporting, :exported, :processing, :shipped, :rejected]
  aasm(:status, whiny_transitions: false) do
    state :incipient, initial: true
    state :submitted
    state :exporting
    state :exported
    state :processing
    state :shipped
    state :rejected
    event :submit do
      transitions from: :incipient, to: :submitted, if: :_submit
    end
    event :export do
      transitions from: :submitted, to: :exporting
    end
    event :complete_export do
      transitions from: :exporting, to: :exported
    end
    event :acknowledge do
      transitions from: :exported, to: :processing
    end
    event :reject do
      transitions from: [:processing, :exported], to: :rejected
    end
    event :ship do
      transitions from: [:exported, :processing], to: :shipped
    end
  end

  def total
    items.reduce(0){|sum, i| sum + i.total_price}
  end

  def shipping_cost
    return nil unless ship_method
    # TODO Need to work out these implementation details
    # maybe we should simply add a shipping_cost attribute to order
    # and recalculate it when triggered or on demand
    return ship_method.cost_calculator.calculate(self)
  end

  def add_item(product_or_sku, quantity = 1)
    sku = product_or_sku.respond_to?(:sku) ? product_or_sku.sku : product_or_sku

    # Force the lookup here, or allow the call to pass in anything product-like?
    product = Product.find_by(sku: sku)
    items.create! sku: product.sku,
                  description: product.description,
                  quantity: quantity,
                  unit_price: product.price
  rescue StandardError => e
    Rails.logger.warn "Error adding product with SKU #{sku} to order #{id}. #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    nil
  end

  def <<(product_or_sku)
    add_item product_or_sku
  end

  def all_items_shipped?
    items.map(&:shipped?).all?
  end

  def updatable?
    incipient?
  end

  def ready_for_submission?
    items.length > 0 &&
      customer_name.present? &&
      shipping_address_id.present? &&
      telephone.present?
  end

  def abbreviated_confirmation
    return nil unless confirmation
    "%s-%s" % confirmation.scan(/.{4}/).map(&:upcase)
  end

  private

  def _submit
    return false unless ready_for_submission?
    self.confirmation = SecureRandom.hex(16)
    save
  end
end

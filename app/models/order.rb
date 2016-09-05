# == Schema Information
#
# Table name: orders
#
#  id                  :integer          not null, primary key
#  customer_name       :string(50)       not null
#  telephone           :string(25)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  order_date          :date             not null
#  batch_id            :integer
#  status              :string(30)       default("incipient"), not null
#  error               :text
#  client_id           :integer          not null
#  client_order_id     :string(100)      not null
#  customer_email      :string(100)
#  ship_method_id      :integer
#  shipping_address_id :integer          not null
#

class Order < ActiveRecord::Base
  include AASM

  has_many :items, class_name: 'OrderItem'
  has_many :shipments
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :batch
  belongs_to :client

  validates_presence_of :client_id,
                        :client_order_id,
                        :customer_name,
                        :order_date,
                        :telephone
  validates_length_of :customer_name,
                       maximum: 50
  validates_length_of [:client_order_id,
                       :customer_email],
                       maximum: 100
  validates_length_of :telephone, maximum: 25
  validates_uniqueness_of :client_order_id

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
      transitions from: :incipient, to: :submitted, if: :ready_for_submission?
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
  end

  def total
    items.reduce(0){|sum, i| sum + i.total_price}
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

  def updatable?
    incipient?
  end

  def ready_for_submission?
    items.length > 0
  end
end

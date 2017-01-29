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
#  delivery_email      :string(100)
#

require 'securerandom'

class Order < ActiveRecord::Base
  include AASM

  has_many :items, ->{order(:line_item_no).distinct}, class_name: 'OrderItem'
  has_many :shipments
  has_many :payments
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :batch
  belongs_to :client
  belongs_to :ship_method

  validates_presence_of :client_id,
                        :order_date
  validates_presence_of :delivery_email, if: ->{ submitted? && electronic_delivery? }
  validates_presence_of :customer_name, if: ->{ submitted? && physical_delivery? }
  validates_presence_of [:shipping_address_id, :telephone], if: ->{ submitted? && physical_delivery? }
  validates_length_of :customer_name,
                       maximum: 50
  validates_length_of [:client_order_id,
                       :customer_email],
                       maximum: 100
  validates_length_of :telephone, maximum: 25
  validates_uniqueness_of :client_order_id, if: :client_order_id
  validates_format_of :delivery_email, with: /\A[^\s@]+@kindle\.com\z/i, if: :delivery_email
  validates_format_of :customer_email, with: /\A[^\s@]+@[^\s@]+\.[a-z]{2,4}\z/i, if: :customer_email
  validate :at_least_one_item, if: :submitted?

  accepts_nested_attributes_for :shipping_address

  scope :by_order_date, ->{order('order_date desc')}
  scope :by_status, ->(status){where(status: status)}
  scope :unbatched, ->{where(batch_id: nil)}
  scope :ready_for_export, ->{unbatched.where(status: :submitted)}

  STATUSES = [:incipient, :submitted, :exporting, :exported, :processing, :shipped, :rejected]
  aasm(:status, whiny_transitions: false) do
    state :incipient, initial: true
    state :submitted, before_enter: :ensure_confirmation
    state :exporting
    state :exported
    state :processing
    state :shipped
    state :rejected
    event :submit do
      transitions from: :incipient, to: :submitted
    end
    event :export do
      transitions from: :submitted, to: :exporting
    end
    event :manual_export do
      transitions from: :submitted, to: :processing
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
                  unit_price: product.price,
                  fulfillment_type: product.fulfillment_type
  rescue StandardError => e
    Rails.logger.warn "Error adding product with SKU #{sku} to order #{id}. #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    nil
  end

  def <<(product_or_sku)
    add_item product_or_sku
  end

  def all_items_shipped?
    items.
      select(&:standard_item?).
      map(&:shipped?).all?
  end

  def updatable?
    incipient?
  end

  def ready_for_submission?
    items.length > 0 &&
      customer_email.present? &&
      physical_delivery_requirements_satisfied? &&
      electronic_delivery_requirements_satisfied?
  end

  def abbreviated_confirmation
    return nil unless confirmation
    "%s-%s" % confirmation.scan(/.{4}/).map(&:upcase)
  end

  def freight_charge
    freight_charge_item.try(:total_price)
  end

  def update_freight_charge!
    freight_charge = calculate_freight_charge
    if freight_charge.present?
      freight_charge = freight_charge.ceil
      if freight_charge_item.present?
        freight_charge_item.update_attribute :unit_price, freight_charge
        items(true)
      else
        items.create! sku: ShipMethod::FREIGHT_CHARGE_SKU,
                      description: 'Shipping & Handling',
                      quantity: 1,
                      unit_price: freight_charge,
                      fulfillment_type: 'none'
      end
    else
      freight_charge_item.destroy! if freight_charge_item.present?
    end
  end

  def reset_line_numbers
    line_item_no = 0
    items.select(&:standard_item?).each do |item|
      line_item_no += 1
      item.line_item_no = line_item_no
      item.save!
    end
    items.select{|i| !i.standard_item?}.each do |item|
      line_item_no += 1
      item.line_item_no = line_item_no
      item.save!
    end
  end

  Product::FULFILLMENT_TYPES.each do |t|
    define_method "#{t}_delivery?" do
      items.any?{|i| i.fulfillment_type == t}
    end
  end

  private

  def physical_delivery_requirements_satisfied?
    return true unless physical_delivery?
    shipping_address_id.present? &&
      telephone.present?
  end

  def electronic_delivery_requirements_satisfied?
    return true unless electronic_delivery?
    delivery_email.present?
  end

  def calculate_freight_charge
    return nil unless items.select(&:standard_item?).any?
    ship_method.try(:calculate_charge, self)
  end

  def freight_charge_item
    @freight_charge_item ||= items.find_by(sku: ShipMethod::FREIGHT_CHARGE_SKU)
  end

  def ensure_confirmation
    self.confirmation ||= SecureRandom.hex(16)
  end

  def at_least_one_item
    errors.add(:items, 'cannot be empty') unless items.any?
  end
end

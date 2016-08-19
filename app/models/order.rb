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
#  status              :string(30)       default("new"), not null
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

  aasm(:status, whiny_transitions: false) do
    state :new, initial: true
    state :exported, :processing, :shipped, :rejected
    event :export do
      transitions from: :new, to: :exported
    end
    event :acknowledge do
      transitions from: :exported, to: :processing
    end
    event :reject do
      transitions from: [:processing, :exported], to: :rejected
    end
  end

  def total
    items.reduce(0){|sum, i| sum + i.total}
  end

  def <<(sku)
    items.create!(sku: sku,
                  quantity: 1,
                  price: 0)
  end

  def updatable?
    new?
  end
end

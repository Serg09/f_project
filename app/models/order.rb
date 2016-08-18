# == Schema Information
#
# Table name: orders
#
#  id              :integer          not null, primary key
#  customer_name   :string(50)       not null
#  address_1       :string(50)       not null
#  address_2       :string(50)
#  city            :string(50)
#  state           :string(100)      not null
#  postal_code     :string(10)
#  country_code    :string(3)
#  telephone       :string(25)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  order_date      :date             not null
#  batch_id        :integer
#  status          :string(30)       default("new"), not null
#  error           :text
#  client_id       :integer          not null
#  client_order_id :string(100)      not null
#  customer_email  :string(100)
#  ship_method_id  :integer
#

class Order < ActiveRecord::Base
  include AASM

  has_many :items, class_name: 'OrderItem'
  has_many :shipments
  belongs_to :batch
  belongs_to :client

  validates_presence_of :client_id,
                        :client_order_id,
                        :customer_name,
                        :order_date,
                        :address_1,
                        :city,
                        :state,
                        :postal_code,
                        :country_code,
                        :telephone
  validates_length_of [:customer_name,
                       :address_1,
                       :address_2,
                       :city],
                       maximum: 50
  validates_length_of [:client_order_id,
                       :customer_email,
                       :state],
                       maximum: 100
  validates_length_of :postal_code, maximum: 10
  validates_length_of :country_code, minimum: 2, maximum: 3
  validates_length_of :telephone, maximum: 25

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

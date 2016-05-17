# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  customer_name :string(50)       not null
#  address_1     :string(50)       not null
#  address_2     :string(50)
#  city          :string(50)
#  state         :string(2)
#  postal_code   :string(10)
#  country_code  :string(3)
#  telephone     :string(25)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  order_date    :date             not null
#

class Order < ActiveRecord::Base
  has_many :items, class_name: 'OrderItem'
  belongs_to :batch

  validates_presence_of :customer_name,
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
  validates_length_of :state, is: 2
  validates_length_of :postal_code, maximum: 10
  validates_length_of :country_code, minimum: 2, maximum: 3
  validates_length_of :telephone, maximum: 25

  scope :by_order_date, ->{order('order_date desc')}
  scope :unbatched, ->{where(batch_id: nil)}

  state_machine :status, initial: :new do
    event :acknowledge do
      transition exported: :processing
    end
    event :reject do
      transition exported: :rejected
    end
  end

  def total
    items.reduce(0){|sum, i| sum + i.total}
  end
end

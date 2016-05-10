class Order < ActiveRecord::Base
  validates_presence_of :customer_name,
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
end

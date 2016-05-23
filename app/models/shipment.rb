class Shipment < ActiveRecord::Base
  belongs_to :order

  validates_presence_of :order_id, :external_id, :ship_date, :quantity
end

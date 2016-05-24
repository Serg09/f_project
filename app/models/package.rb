class Package < ActiveRecord::Base
  belongs_to :shipment_item

  validates_presence_of :shipment_item_id
end

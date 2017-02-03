# == Schema Information
#
# Table name: shipment_items
#
#  id               :integer          not null, primary key
#  shipment_id      :integer          not null
#  order_item_id    :integer          not null
#  external_line_no :integer          not null
#  shipped_quantity :integer          not null
#  cancel_code      :string
#  cancel_reason    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ShipmentItem < ActiveRecord::Base
  belongs_to :shipment
  belongs_to :order_item
  has_many :packages

  validates_presence_of :shipment_id, :order_item_id, :shipped_quantity
end

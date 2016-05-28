# == Schema Information
#
# Table name: packages
#
#  id               :integer          not null, primary key
#  shipment_item_id :integer          not null
#  package_id       :string
#  tracking_number  :string
#  quantity         :integer
#  weight           :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Package < ActiveRecord::Base
  belongs_to :shipment_item

  validates_presence_of :shipment_item_id
end

# == Schema Information
#
# Table name: shipments
#
#  id                     :integer          not null, primary key
#  order_id               :integer          not null
#  external_id            :string           not null
#  ship_date              :date             not null
#  quantity               :integer          not null
#  weight                 :decimal(, )
#  freight_charge         :decimal(, )
#  handling_charge        :decimal(, )
#  collect_freight        :boolean          default(FALSE), not null
#  freight_responsibility :string
#  cancel_code            :string
#  cancel_reason          :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Shipment < ActiveRecord::Base
  belongs_to :order

  validates_presence_of :order_id, :external_id, :ship_date, :quantity
end

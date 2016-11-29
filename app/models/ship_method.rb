class ShipMethod < ActiveRecord::Base
  belongs_to :carrier
  validates_presence_of :description, :carrier_id, :abbreviation
  validates_length_of :description, maximum: 100
  validates_length_of :abbreviation, maximum: 20
  validates_uniqueness_of :description, scope: :carrier_id
  validates_uniqueness_of :abbreviation
end

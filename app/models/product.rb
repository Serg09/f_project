class Product < ActiveRecord::Base
  validates_presence_of :sku, :description, :price
  validates_uniqueness_of :sku
  validates_length_of :sku, maximum: 20
  validates_length_of :description, maximum: 256
  validates_numericality_of :price, greater_than: 0, if: :price
end

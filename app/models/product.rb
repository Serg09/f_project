# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  sku         :string(30)       not null
#  description :string(256)      not null
#  price       :decimal(9, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Product < ActiveRecord::Base
  validates_presence_of :sku, :description, :price
  validates_uniqueness_of :sku
  validates_length_of :sku, maximum: 20
  validates_length_of :description, maximum: 256
  validates_numericality_of :price, greater_than: 0, if: :price
end

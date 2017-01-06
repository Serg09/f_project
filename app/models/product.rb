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
#  weight      :decimal(7, 2)    not null
#

class Product < ActiveRecord::Base
  FULFILLMENT_TYPES = %w(physical electronic)

  FULFILLMENT_TYPES.each do |t|
    define_method "#{t}?" do
      fulfillment_type == t
    end
  end

  validates_presence_of :sku, :description, :price, :fulfillment_type
  validates_presence_of :weight, if: :physical?
  validates_uniqueness_of :sku
  validates_inclusion_of :fulfillment_type, in: FULFILLMENT_TYPES
  validates_length_of :sku, maximum: 20
  validates_length_of :description, maximum: 256
  validates_numericality_of :price, greater_than: 0, if: :price
  validates_numericality_of :weight, greater_than: 0, if: :weight
end

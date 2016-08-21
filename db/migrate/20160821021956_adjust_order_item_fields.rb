class AdjustOrderItemFields < ActiveRecord::Migration
  def change
    rename_column :order_items, :price, :unit_price
    rename_column :shipment_items, :price, :unit_price
  end
end

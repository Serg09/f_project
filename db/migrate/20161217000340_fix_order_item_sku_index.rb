class FixOrderItemSkuIndex < ActiveRecord::Migration
  def up
    remove_index :order_items, :sku
    add_index :order_items, [:order_id, :sku], unique: true
  end

  def down
    remove_index :order_items, [:order_id, :sku]
    add_index :order_items, :sku
  end
end

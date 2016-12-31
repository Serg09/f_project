class RelaxConstraintOnLineItemNo < ActiveRecord::Migration
  def up
    remove_index :order_items, [:order_id, :line_item_no]
    add_index :order_items, [:order_id, :line_item_no]
  end

  def down
    remove_index :order_items, [:order_id, :line_item_no]
    add_index :order_items, [:order_id, :line_item_no], unique: true
  end
end

class AddWeightToOrderItems < ActiveRecord::Migration
  def up
    add_column :order_items, :weight, :decimal
    change_column :order_items, :description, limit: 250
  end

  def down
    remove_column :order_items, :weight
    change_column :order_items, :description, limit: 50
  end
end

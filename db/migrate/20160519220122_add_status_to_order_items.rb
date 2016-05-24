class AddStatusToOrderItems < ActiveRecord::Migration
  def change
    change_table :order_items do |t|
      t.string :status, limit: 30, null: false, default: 'new'
      t.integer :accepted_quantity
      t.integer :shipped_quantity
    end
  end
end

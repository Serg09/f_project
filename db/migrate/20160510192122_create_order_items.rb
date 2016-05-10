class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id, null: false
      t.integer :line_item_no, null: false
      t.string :sku, null: false, limit: 30
      t.string :description, limit: 50
      t.integer :quantity, null: false
      t.decimal :price
      t.decimal :discount_percentage
      t.decimal :freight_charge
      t.decimal :tax

      t.index [:order_id, :line_item_no], unique: true
      t.index :sku

      t.timestamps null: false
    end
  end
end

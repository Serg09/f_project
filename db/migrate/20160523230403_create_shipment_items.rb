class CreateShipmentItems < ActiveRecord::Migration
  def change
    create_table :shipment_items do |t|
      t.integer :shipment_id, null: false
      t.integer :order_item_id, null: false
      t.integer :external_line_no, null: false
      t.string :sku, null: false
      t.decimal :price
      t.integer :shipped_quantity, null: false
      t.string :cancel_code
      t.string :cancel_reason

      t.timestamps null: false

      t.index [:shipment_id, :order_item_id]
      t.index :sku
    end
  end
end

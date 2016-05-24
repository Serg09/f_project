class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.integer :shipment_item_id, null: false
      t.string :package_id
      t.string :tracking_number
      t.integer :quantity
      t.decimal :weight

      t.timestamps null: false

      t.index :shipment_item_id
      t.index :package_id
      t.index :tracking_number
    end
  end
end

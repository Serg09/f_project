class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :order_id, null: false
      t.string :external_id, null: false
      t.date :ship_date, null: false
      t.integer :quantity, null: false
      t.decimal :weight
      t.decimal :freight_charge
      t.decimal :handling_charge
      t.boolean :collect_freight, null: false, default: false
      t.string :freight_responsibility
      t.string :cancel_code
      t.string :cancel_reason

      t.timestamps null: false

      t.index :order_id
      t.index :external_id
      t.index :ship_date
    end
  end
end

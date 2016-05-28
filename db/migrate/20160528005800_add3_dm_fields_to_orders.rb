class Add3DmFieldsToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.integer :client_id, null: false
      t.string :client_order_id, null: false, limit: 100
      t.string :customer_email, limit: 100
      t.integer :ship_method_id

      t.index :client_id
      t.index :client_order_id, unique: true
      t.index :ship_method_id
    end
  end
end

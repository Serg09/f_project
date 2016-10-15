class RelaxOrderConstraints < ActiveRecord::Migration
  def up
    change_column :orders, :customer_name, :string, limit: 50, null: true
    change_column :orders, :shipping_address_id, :int, null: true
  end

  def down
    change_column :orders, :customer_name, :string, limit: 50, null: false
    change_column :orders, :shipping_address_id, :int, null: false
  end
end

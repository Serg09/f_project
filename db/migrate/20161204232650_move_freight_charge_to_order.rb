class MoveFreightChargeToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :freight_charge, :decimal, precision: 9, scale: 2
    remove_column :order_items, :freight_charge
  end

  def down
    add_column :order_items, :freight_charge, :decimal
    remove_column :orders, :freight_charge
  end
end

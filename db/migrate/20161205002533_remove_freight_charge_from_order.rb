class RemoveFreightChargeFromOrder < ActiveRecord::Migration
  def up
    remove_column :orders, :freight_charge
  end

  def down
    add_column :orders, :freight_charge, :decimal, precision: 9, scale: 2
  end
end

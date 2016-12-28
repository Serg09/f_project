class AddActiveToShipMethods < ActiveRecord::Migration
  def change
    add_column :ship_methods, :active, :boolean, null: false, default: false
  end
end

class AddCalculatorClassToShipMethod < ActiveRecord::Migration
  def change
    add_column :ship_methods, :calculator_class, :string, null: false, limit: 256
  end
end

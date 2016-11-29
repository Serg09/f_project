class CreateShipMethods < ActiveRecord::Migration
  def change
    create_table :ship_methods do |t|
      t.integer :carrier_id, null: false
      t.string :description, null: false, limit: 100
      t.string :abbreviation, null: false, limit: 20

      t.timestamps null: false

      t.index [:carrier_id, :description], unique: true
      t.index :abbreviation, unique: true
    end
  end
end

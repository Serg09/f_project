class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :sku, null: false, limit: 20
      t.string :description, null: false, limit: 256
      t.decimal :price, precision: 9, scale: 2

      t.timestamps null: false
      t.index :sku, unique: true
    end
  end
end

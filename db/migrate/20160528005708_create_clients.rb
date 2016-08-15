class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name, null: false, limit: 100
      t.string :abbreviation, null: false, limit: 5

      t.timestamps null: false

      t.index :name, unique: true
      t.index :abbreviation, unique: true
    end
  end
end

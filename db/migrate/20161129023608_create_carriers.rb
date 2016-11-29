class CreateCarriers < ActiveRecord::Migration
  def change
    create_table :carriers do |t|
      t.string :name, null: false, limit: 100

      t.timestamps null: false

      t.index :name, unique: true
    end
  end
end

class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :isbn, null: false, limit: 13
      t.string :title, null: false, limit: 250
      t.string :format, null: false, limit: 100

      t.timestamps null: false

      t.index :isbn, unique: true
      t.index :title
    end
  end
end

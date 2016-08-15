class CreateBookIdentifiers < ActiveRecord::Migration
  def change
    create_table :book_identifiers do |t|
      t.integer :client_id, null: false
      t.integer :book_id, null: false
      t.string :code, null: false, limit: 20

      t.timestamps null: false

      t.index [:client_id, :code], unique: true
      t.index :book_id
    end
  end
end

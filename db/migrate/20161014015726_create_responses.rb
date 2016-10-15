class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :payment_id, null: false
      t.string :status, null: false
      t.text :content, null: false

      t.timestamps null: false
      t.index :payment_id
    end
  end
end

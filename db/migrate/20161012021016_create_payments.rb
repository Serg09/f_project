class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :order_id, null: false
      t.decimal :amount, null: false, precision: 9, scale: 2
      t.string :state, null: false, limit: 20
      t.string :external_id, limit: 100
      t.decimal :external_fee, precision: 9, scale: 2

      t.timestamps null: false
      t.index :order_id
      t.index :external_fee, unique: true
    end
  end
end

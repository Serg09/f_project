class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :recipient, null: false, limit: 100
      t.string :line_1, null: false, limit: 100
      t.string :line_2, limit: 100
      t.string :city, null: false, limit: 100
      t.string :state, null: false, limit: 20
      t.string :postal_code, null: false, limit: 10
      t.string :country_code, null: false, limit: 2

      t.timestamps null: false
    end
  end
end

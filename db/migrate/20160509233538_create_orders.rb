class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :customer_name, null: false, limit: 50
      t.string :address_1, null: false, limit: 50
      t.string :address_2, limit: 50
      t.string :city, limit: 50
      t.string :state, limit: 2
      t.string :postal_code, limit: 10
      t.string :country_code, limit: 3
      t.string :telephone, limit: 25

      t.timestamps null: false
    end
  end
end

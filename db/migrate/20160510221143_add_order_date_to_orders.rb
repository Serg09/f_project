class AddOrderDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_date, :date, null: false
  end
end

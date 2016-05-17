class AddStatusToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :status, :string, limit: 30, null: false, default: 'new'
  end
end

class RelaxClientOrderIdConstraint < ActiveRecord::Migration
  def up
    change_column :orders, :client_order_id, :string, limit: 100, null: true
  end

  def down
    change_column :orders, :client_order_id, :string, limit: 100, null: false
  end
end

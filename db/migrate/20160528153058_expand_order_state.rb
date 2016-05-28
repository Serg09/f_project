class ExpandOrderState < ActiveRecord::Migration
  def up
    change_column :orders, :state, :string, null: false, limit: 100
  end

  def down
    change_column :orders, :state, :string, null: false, limit: 2
  end
end

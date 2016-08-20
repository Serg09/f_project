class ChangeOrderStatusDefault < ActiveRecord::Migration
  def up
    change_column :orders, :status, :string, limit: 30, null: false, default: 'incipient'
  end

  def down
    change_column :orders, :status, :string, limit: 30, null: false, default: 'new'
  end
end

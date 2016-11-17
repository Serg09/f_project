class AddConfirmationToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :confirmation, :string, limit: 32
    add_index :orders, :confirmation, unique: true
  end
end

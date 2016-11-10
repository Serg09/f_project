class CorrectExternalIdIndex < ActiveRecord::Migration
  def up
    remove_index :payments, :external_fee
    add_index :payments, :external_id, unique: true
  end

  def down
    remove_index :payments, :external_id
    add_index :payments, :external_fee, unique: true
  end
end

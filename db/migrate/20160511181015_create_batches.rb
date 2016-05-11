class CreateBatches < ActiveRecord::Migration
  def up
    create_table :batches do |t|
      t.string :status, null: false, default: 'new'
      t.timestamps null: false
    end
    add_column :orders, :batch_id, :integer
    add_index :orders, :batch_id
  end

  def down
    remove_index :orders, :batch_id
    remove_column :orders, :batch_id
    drop_table :batches
  end
end

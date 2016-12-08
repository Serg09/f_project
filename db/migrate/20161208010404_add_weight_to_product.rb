class AddWeightToProduct < ActiveRecord::Migration
  def up
    add_column :products, :weight, :decimal, precision: 7,
                                             scale: 2
    ActiveRecord::Base.connection.execute('update products set weight = 1 where weight is null;')
    change_column :products, :weight, :decimal, null: false,
                                                precision: 7,
                                                scale: 2
  end

  def down
    remove_column :products, :weight
  end
end

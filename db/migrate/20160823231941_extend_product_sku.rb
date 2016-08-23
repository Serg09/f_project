class ExtendProductSku < ActiveRecord::Migration
  def up
    change_column :products, :sku, :string, null: false, limit: 30
  end

  def down
    change_column :products, :sku, :string, null: false, limit: 20
  end
end

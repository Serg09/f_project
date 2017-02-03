class RemoveRedundantShipmentItemFields < ActiveRecord::Migration
  def up
    remove_column :shipment_items, :sku
    remove_column :shipment_items, :unit_price
  end

  def down
    add_column :shipment_items, :sku, :string
    add_column :shipment_items, :unit_price, :decimal

    ActiveRecord::Base.connection.execute <<-SQL
      update shipment_items set
        sku = i.sku
      from order_items i
      where i.id = shipment_items.order_item_id
    SQL

    change_column :shipment_items, :sku, :string, null: false
  end
end

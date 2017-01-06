class AddDeliveryEmailToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :delivery_email, :string, limit: 100
    add_column :order_items, :fulfillment_type, :string, limit: 15, null: false, default: 'physical'
    add_column :products, :fulfillment_type, :string, limit: 15, null: false, default: 'physical'
    change_column :products, :weight, :decimal, null: true,
                                                precision: 7,
                                                scale: 2
  end

  def down
    remove_column :orders, :delivery_email
    remove_column :order_items, :fulfillment_type
    remove_column :products, :fulfillment_type
    change_column :products, :weight, :decimal, null: false,
                                                precision: 7,
                                                scale: 2
  end
end

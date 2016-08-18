class ExtractAddressFromOrder < ActiveRecord::Migration
  def up
    add_column :orders, :shipping_address_id, :integer

    address_sql = <<-EOS
      select
        id as order_id,
        address_1 as line_1,
        address_2 as line_2,
        city,
        state,
        postal_code,
        country_code,
        customer_name as recipient
      from orders
    EOS
    orders = ActiveRecord::Base.connection.execute(address_sql)
    orders.each do |order|

      puts order.inspect

      order_id = order.delete('order_id')
      address = Address.create! order
      update_order_sql = <<-EOS
        update orders set
        shipping_address_id=#{address.id}
        where id=#{order_id}
      EOS
      ActiveRecord::Base.connection.execute(update_order_sql)
    end

    change_column :orders, :shipping_address_id, :integer, null: false

    remove_column :orders, :address_1
    remove_column :orders, :address_2
    remove_column :orders, :city
    remove_column :orders, :state
    remove_column :orders, :postal_code
    remove_column :orders, :country_code
  end

  def down
    change_table :orders do |t|
      t.string :address_1, limit: 50
      t.string :address_2, limit: 50
      t.string :city, limit: 50
      t.string :state, limit: 2
      t.string :postal_code, limit: 10
      t.string :country_code, limit: 3
    end

    sql = <<-EOS
      select
        o.id as order_id,
        a.id as address_id,
        a.line_1 as address_1,
        a.line_2 as address_2,
        a.city,
        a.state,
        a.postal_code,
        a.country_code
      from orders o
        inner join addresses a on a.id = o.shipping_address_id
    EOS
    addresses = ActiveRecord::Base.connection.execute(sql)
    addresses.each do |address|
      order_id = address.delete 'order_id'
      address_id = address.delete 'address_id'
      order = Order.find order_id
      order.update_attributes address
      order.save!
      ActiveRecord::Base.connection.execute("delete from addresses where id=#{address_id}")
    end

    change_column :orders, :address_1, :string, null: false, limit: 50
    remove_column :orders, :shipping_address_id
  end
end

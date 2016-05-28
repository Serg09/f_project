require 'csv'
require 'pp'

module ThreeDM
  class OrderImporter
    def self.order_field_map
      @order_field_map ||= {}
    end

    def self.item_field_map
      @item_field_map ||= {}
    end

    def self.add_order_field_mapping(external_field, internal_field)
      order_field_map[external_field] = internal_field
    end

    def self.add_item_field_mapping(external_field, internal_field)
      item_field_map[external_field] = internal_field
    end

    add_order_field_mapping(:orderid, :client_order_id)
    add_order_field_mapping(:odate, :order_date)
    add_order_field_mapping(:oemail, :customer_email)
    add_order_field_mapping(:oshipmethod, :ship_method_id)
    add_order_field_mapping([:oshipfirstname, :oshiplastname], :customer_name)
    add_order_field_mapping(:oshipaddress, :address_1)
    add_order_field_mapping(:oshipaddress2, :address_2)
    add_order_field_mapping(:oshipcity, :city)
    add_order_field_mapping(:oshipstate, :state)
    add_order_field_mapping(:oshipzip, :postal_code)
    add_order_field_mapping(:oshipcountry, :country_code)
    add_order_field_mapping(:oshipphone, :telephone)

    add_item_field_mapping(:itemid, :sku)
    add_item_field_mapping(:itemname, :description)
    add_item_field_mapping(:numitems, :quantity)
    add_item_field_mapping(:unit_price, :price)
    add_item_field_mapping(:weight, :weight)


    def initialize(content, client)
      @content = content
      @client = client
    end

    def process
      headers = nil
      CSV.parse(@content) do |row|
        if headers.nil?
          headers = row
        else
          hash = [headers, row].transpose.to_h.with_indifferent_access
          process_row(hash)
        end
      end
    end

    private

    def process_row(row)
      order_map = to_order_map(row)
      @order = create_or_keep_order(order_map)

      item_map = to_item_map(row)
      add_order_item(item_map)
    end

    def add_order_item(item_map)
      item = @order.items.lazy.select{|i| i.sku == item_map[:sku]}.first
      if item
        item.quantity += item_map[:quantity].to_i
        item.save!
      else
        @order.items.create! item_map
      end
    end

    def create_or_keep_order(order_map)
      if @order.try(:client_order_id) == order_map[:client_order_id]
        @order
      else
        Order.create! order_map.merge(client: @client)
      end
    end

    def to_order_map(row)
      map_fields(row, self.class.order_field_map) #TODO Add the client ID
    end

    def count
      @count ||= 0
    end

    def count=(value)
      @count = value
    end

    def to_item_map(row)
      map_fields row, self.class.item_field_map
    end

    def map_fields(row, field_map)
      field_map.reduce({}) do |result, pair|
        if pair.first.is_a? Array
          result[pair.second] = pair.first.map{|k| row[k]}.join(" ")
        else
          result[pair.second] = row[pair.first]
        end
        result
      end
    end
  end
end

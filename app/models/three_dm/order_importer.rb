require 'csv'

module ThreeDM
  class OrderImporter
    def initialize(content)
      @content = content
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
      @order = create_or_keep_order(row)
      #add_order_item(row)
    rescue => e
      Rails.logger.error "Unable to import row #{row.inspect}"
    end

    def create_order(row)
      #TODO Add :client_order_id, :client_id
      Order.create! customer_name: "#{row[:ofirstname]} #{row[:olastname]}",
                    address_1: row[:oaddress],
                    address_2: row[:oaddress2],
                    city: row[:ocity],
                    state: row[:ostate],
                    postal_code: row[:ozip],
                    country_code: row[:ocountry],
                    order_date: row[:odate],
                    telephone: row[:ophone]
    end

    def create_or_keep_order(row)
      if @order.try(:customer_order_id) == row[:orderid]
        @order
      else
        create_order(row)
      end
    end
  end
end

require 'rails_helper'

describe OrderCsvExporter do
  let!(:product_1) { FactoryGirl.create :product, sku: '123456', description: 'deluxe widget' }
  let!(:product_2) { FactoryGirl.create :product, sku: '654321', description: 'standard widget' }
  let (:ship_method) { FactoryGirl.create :ship_method, abbreviation: 'DONKEY' }
  let (:address_1) do
    FactoryGirl.create :address,
      recipient: 'Sally Readerton',
      line_1: '1234 Main St',
      line_2: 'Apt 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75225',
      country_code: 'US'
  end
  let!(:order_1) do
    FactoryGirl.create :submitted_order,
      ship_method_id: ship_method.id,
      shipping_address_id: address_1.id,
      telephone: '2145551212',
      item_attributes: [
        {sku: '123456'}
      ]
  end
  let (:address_2) do
    FactoryGirl.create :address,
      recipient: 'Sir Billy Bottington Bookworm Esquire and some other long name words',
      line_1: '4321 Elm St',
      line_2: nil,
      city: 'Dallas',
      state: 'TX',
      postal_code: '75201',
      country_code: 'US'
  end
  let!(:order_2) do
    FactoryGirl.create :submitted_order,
      ship_method_id: ship_method.id,
      shipping_address_id: address_2.id,
      telephone: '2145554321',
      item_attributes: [
        {sku: '123456', quantity: 2},
        {sku: '654321'}
      ]
  end

  describe '#content' do
    let (:raw_expected_content) do
      <<-EOS
        SKU,Description,Quantity,Order ID,Line Item No,"",Ship Method,Recipient,Address 1,Address 2,City,State,Postal Code,Country Code,Telephone
        123456,deluxe widget,1,000001,1,,DONKEY,Sally Readerton,1234 Main St,Apt 227,Dallas,TX,75225,US,2145551212
        123456,deluxe widget,2,000002,1,,DONKEY,Sir Billy Bottington Bookworm Esquire and som,4321 Elm St,,Dallas,TX,75201,US,2145554321
        654321,standard widget,1,000002,2,,DONKEY,Sir Billy Bottington Bookworm Esquire and som,4321 Elm St,,Dallas,TX,75201,US,2145554321
      EOS
    end

    let (:expected_content) do
      raw_expected_content.strip.gsub(/\n\s+/, "\n") + "\n"
    end

    it 'contains the order details' do
      exporter = OrderCsvExporter.new(Order.all)
      expect(exporter.content).to eq expected_content
    end
  end
end

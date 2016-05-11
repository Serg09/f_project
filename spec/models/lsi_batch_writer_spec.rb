require 'rails_helper'

describe LsiBatchWriter do
  let (:batch) { FactoryGirl.create(:batch) }
  let (:order) do
    FactoryGirl.create(:order, order_date: '2016-03-02',
                               customer_name: 'John Doe',
                               address_1: '1234 Main St',
                               address_2: 'Apt 227',
                               city: 'Dallas',
                               state: 'TX',
                               postal_code: '75200',
                               country_code: 'USA',
                               telephone: '214-555-1212',
                               batch: batch,
                               created_at: '2016-03-02 12:30:42 CST')
  end
  let!(:item) do
    FactoryGirl.create(:order_item, order: order,
                                    line_item_no: 1,
                                    sku: 'ABC123',
                                    quantity: 1,
                                    price: 19.99,
                                    discount_percentage: 0.10,
                                    freight_charge: 1.99,
                                    tax: 1.65)
  end
  let (:expected_output_path) do
    path = Rails.root.join('spec', 'fixtures', 'files', 'lsi_batch_writer_expected_output.txt')
  end

  describe '#write' do
    it 'writes the batch content to the specified IO object' do
      writer = LsiBatchWriter.new(batch)
      io = StringIO.new
      writer.write io

      io.rewind
      File.open(expected_output_path) do |f|
        f.each_line do |l|
          expect(io.readline).to eq l
        end
      end
    end
  end
end

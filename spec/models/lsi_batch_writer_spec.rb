require 'rails_helper'

describe LsiBatchWriter do
  let (:batch) { FactoryGirl.create(:batch) }
  let (:order) do
    Timecop.freeze(DateTime.parse('2016-03-02 06:30:42 CST')) do
      FactoryGirl.create(:order, order_date: '2016-02-27',
                                 customer_name: 'John Doe',
                                 address_1: '1234 Main St',
                                 address_2: 'Apt 227',
                                 city: 'Dallas',
                                 state: 'TX',
                                 postal_code: '75200',
                                 country_code: 'USA',
                                 telephone: '214-555-1212',
                                 batch: batch)
    end
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
  let (:writer) { LsiBatchWriter.new(batch) }

  describe '#write' do
    it 'writes the batch content to the specified IO object' do
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

  describe '#alpha_of_length' do
    it 'up-cases and right-pads the value with blank spaces if it is shorter than the specified length' do
      expect(writer.alpha_of_length("test", 6)).to eq "TEST  "
    end

    it 'truncates the value if it is longer than the specified length' do
      expect(writer.alpha_of_length("thisistoolong", 4)).to eq "THIS"
    end

    it 'returns the value as-if if it is extactly the specified length' do
      expect(writer.alpha_of_length("justright", 9)).to eq "JUSTRIGHT"
    end
  end

  describe '#number_of_length' do
    it 'returns a string' do
      expect(writer.number_of_length(10, 2)).to be_a String
    end

    it 'left-pads the value with zeros if it is shorter than the specified length' do
      expect(writer.number_of_length(1, 5)).to eq "00001"
    end

    it 'raises and exception if the value is longer than the specified length' do
      expect do
        writer.number_of_length(100, 2)
      end.to raise_error ArgumentError, "The value 100 is longer than the specified length 2"
    end
  end
end

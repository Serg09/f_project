require 'rails_helper'

describe Lsi::AsnWriter do
  let (:order) do
    {
      order_id: 123456,
      order_date: Date.parse('2016-03-02'),
      batch_id: 234567,
      batch_date_time: DateTime.parse('2016-03-02 12:34:56'),
      customer_id: 100,
      items: [
        {
          line_item_no: 1,
          sku: '654321',
          quantity: 2,
          unit_price: 19.99
        }
      ]
    }
  end

  describe '#perform' do
    it 'delivers the file to the remote file provider' do
      writer = Lsi::AsnWriter.new order
      expect(REMOTE_FILE_PROVIDER).to \
        receive(:send_file).
        with(anything, /^M\d{7}\.PBS$/, 'outgoing') do |content, filename, directory|
          puts "filename=#{filename}"
          puts "content"
          puts content.read
        end
      writer.perform
    end
  end
end

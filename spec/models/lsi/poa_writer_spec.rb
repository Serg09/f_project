require 'rails_helper'

describe Lsi::PoaWriter do
  let (:batch) do
    {
      batch_id: 234567,
      batch_date_time: '2016-03-02 12:34:56',
      orders: [
        {
          order_id: 123456,
          order_date: '2016-03-02',
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
      ]
    }
  end

  describe '#perform' do
    it 'delivers the file to the remote file provider' do
      writer = Lsi::PoaWriter.new batch
      expect(REMOTE_FILE_PROVIDER).to \
        receive(:send_file).
        with(anything, /^M\d{7}\.PPR$/, 'outgoing')
      writer.perform
    end
  end
end

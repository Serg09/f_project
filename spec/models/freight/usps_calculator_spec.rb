require 'rails_helper'

describe Freight::UspsCalculator do
  let (:product) { FactoryGirl.create :product, weight: 1.3 }
  let (:order) { FactoryGirl.create(:order) }
  let (:calculator) { Freight::UspsCalculator.new order }
  let (:response_body) do
    <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <RateV4Response>
        <Package ID="xyz">
          <ZipOrigination>75075</ZipOrigination>
          <ZipDestination>75225</ZipDestination>
          <Pounds>2</Pounds>
          <Ounces>6</Ounces>
          <Container>RECTANGULAR</Container>
          <Size>LARGE</Size>
          <Zone>1</Zone>
          <Postage CLASSID="1">
            <MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt;</MailService>
            <Rate>7.35</Rate>
          </Postage>
        </Package>
      </RateV4Response>
    XML
  end
  let (:http_response) { double 'HttpResponse', body: response_body }
  before { order.add_item product.sku, 2 }

  describe '#rate' do
    it 'returns the freight cost for the specified order' do
      expect(HTTParty).to receive(:get).
        and_return(http_response)
      expect(calculator.rate).to eq 7.35
    end

    it 'sends a request with the correct order weight' do
      expect(HTTParty).to \
        receive(:get).
        with(usps_param('Pounds', '1')).
        and_return(http_response)

      calculator.rate
    end

    it 'sends a request with the correct origination postal code'
    it 'sends a request with the correct destination postal code'
    it 'sends a request with the correct container'
    it 'sends a request with the correct size'
    it 'sends a request with the correct width'
    it 'sends a request with the correct length'
    it 'sends a request with the correct height'
    it 'sends a request with the correct girth'
  end
end

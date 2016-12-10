require 'rails_helper'

describe Freight::UspsCalculator do
  let (:product) { FactoryGirl.create :product, weight: 1.3 }
  let (:address) { FactoryGirl.create :address, postal_code: '75225' }
  let (:ship_method) { FactoryGirl.create :ship_method }
  let (:order) do
    FactoryGirl.create(:order, shipping_address: address,
                               ship_method: ship_method)
  end
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

    tests = [
      {
        css: 'Pounds',
        expected: '2',
        description: 'weight (pounds)'
      },
      {
        css: 'Ounces',
        expected: '10',
        description: 'weight (ounces)'
      },
      {
        css: 'ZipOrigination',
        expected: '37086',
        description: 'origination postal code'
      },
      {
        css: 'ZipDestination',
        expected: '75225',
        description: 'destination postal code'
      },
      {
        css: 'Container',
        expected: 'RECTANGULAR',
        description: 'container'
      },
      {
        css: 'Size',
        expected: 'LARGE',
        description: 'size'
      },
      {
        css: 'Width',
        expected: '12',
        description: 'width'
      },
      {
        css: 'Height',
        expected: '12',
        description: 'height'
      },
      {
        css: 'Length',
        expected: '12',
        description: 'length'
      },
      {
        css: 'Girth',
        expected: '48',
        description: 'grith'
      }
    ]
    tests.select{|t| t[:expected]}.each do |test|
      it "sends a request with the correct #{test[:description]}" do
        expect(HTTParty).to \
          receive(:get).
          with(usps_param(test[:css], test[:expected])).
          and_return(http_response)

        calculator.rate
      end
    end
    tests.reject{|t| t[:expected]}.each do |test|
      it "sends a request with the correct #{test[:description]}"
    end

    # USPS1P   USPS Priority
    # USPSBP   USPS Media
    # USPSBPAH USPS AK/HI
    context 'when ship method "USPS1P" is selected' do
      let (:ship_method) { FactoryGirl.create :ship_method, abbreviation: 'USPS1P' }
      it "sends a request with the correct service" do
        expect(HTTParty).to \
          receive(:get).
          with(usps_param('Service', 'PRIORITY')).
          and_return(http_response)

        calculator.rate
      end
    end

    context 'when ship method "USPS1P" is selected' do
      let (:ship_method) { FactoryGirl.create :ship_method, abbreviation: 'USPS1P' }
      it "sends a request with the 'PRIORITY' service" do
        expect(HTTParty).to \
          receive(:get).
          with(usps_param('Service', 'PRIORITY')).
          and_return(http_response)

        calculator.rate
      end
    end

    context 'when ship method "USPSBP" is selected' do
      let (:ship_method) { FactoryGirl.create :ship_method, abbreviation: 'USPSBP' }
      it "sends a request with the 'MEDIA' service" do
        expect(HTTParty).to \
          receive(:get).
          with(usps_param('Service', 'MEDIA')).
          and_return(http_response)

        calculator.rate
      end
    end

    context 'when ship method "USPSBPAH" is selected' do
      let (:ship_method) { FactoryGirl.create :ship_method, abbreviation: 'USPSBPAH' }
      it "sends a request with the 'PRIORITY' service" do
        expect(HTTParty).to \
          receive(:get).
          with(usps_param('Service', 'PRIORITY')).
          and_return(http_response)

        calculator.rate
      end
    end
  end
end

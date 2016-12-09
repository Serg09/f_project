require 'nokogiri'
require 'uri'

module Freight
  class UspsCalculator < BaseCalculator
    def self.configure
      klass = Struct.new('UspsCalculatorConfiguration', :origination_postal_code, :username)
      @@config = klass.new(nil, nil)
      yield @@config
    end

    def initialize(order)
      self.order = order
    end

    def rate
      @rate ||= calculate_rate
    end

    private

    def calculate_rate
      response = HTTParty.get(uri.to_s)
      xml = Nokogiri::XML(response.body)
      return xml.at_css('Rate').content.to_f if xml.at_css('Rate')
      raise "Unable to get the rate from USPS: #{xml.at_css('Error/Description').content}"
    end

    def uri
      URI::HTTP.build \
        host: 'production.shippingapiscom',
        path: '/ShippingApi.dll',
        query: {
          API: 'RateV4',
          XML: request_xml
        }.map{|k,v| "#{k}=#{v}"}.join('&')
    end

    def request_xml
      Nokogiri::XML::Builder.new do |xml|
        xml.RateV4Request(USERID: @@config.username) do
          xml.Package(ID: SecureRandom.uuid) do
            xml.Service 'PRIORITY' # TODO get this from the shipping method
            xml.ZipOrigination @@config.origination_postal_code
            xml.ZipDestination order.shipping_address.postal_code
            xml.Pounds total_weight.floor
            xml.Ounces ((total_weight % 1) * 16).round
            xml.Container 'RECTANGULAR' # TODO just guess about these?
            xml.Size 'LARGE'
            xml.Width 12
            xml.Length 12
            xml.Height 12
            xml.Girth 48
          end
        end
      end.to_xml
    end
  end
end

require 'nokogiri'
require 'uri'

namespace :usps do
  desc 'Get a rate quote'
  task rate: :environment do
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.RateV4Request do
        xml.Package do
          xml.Service 'PRIORITY'
          xml.ZipOrigination '75200'
          xml.ZipDestination '75201'
          xml.Pounds 5
          xml.Ounces 6
          xml.Container 'RECTANGULAR'
          xml.Size 'LARGE'
          xml.Width 12
          xml.Length 12
          xml.Height 12
          xml.Girth 48
        end
      end
    end

    uri = URI::HTTP.build host: 'production.shippingapis.com',
      path: '/ShippingApi.dll',
      query: "API=RateV4&XML=#{builder.to_xml}"

    puts "xml=#{builder.to_xml noblanks: true}"
    puts uri.to_s
  end
end

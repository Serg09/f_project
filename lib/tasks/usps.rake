require 'nokogiri'
require 'uri'

namespace :usps do
  desc 'Get a rate quote'
  task rate: :environment do
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.RateV4Request(USERID: ENV['USPS_USERNAME']) do
        xml.Package(ID: '1st') do
          xml.Service 'PRIORITY'
          xml.ZipOrigination '75075'
          xml.ZipDestination '75225'
          xml.Pounds 2
          xml.Ounces 6
          xml.Container 'RECTANGULAR'
          xml.Size 'LARGE'
          xml.Width 12
          xml.Length 24
          xml.Height 12
          xml.Girth 48
        end
      end
    end

    uri = URI::HTTP.build host: 'production.shippingapis.com',
      path: '/ShippingApi.dll',
      query: {
        API: 'RateV4',
        XML: builder.to_xml
      }.map{|k,v| "#{k}=#{v}"}.join('&')

    response = HTTParty.get uri.to_s
    xml = Nokogiri::XML(response.body)

    rate = xml.at_css('Rate')
    puts "Rate: #{rate.content}" if rate
    error = xml.at_css('Error/Description')
    puts "Error: #{error.content}" if error
  end
end

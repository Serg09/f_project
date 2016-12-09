require 'nokogiri'
require 'uri'

RSpec::Matchers.define :usps_param do |css, expected|
  match do |actual|
    uri = URI(actual)

    array  = uri.query.
      split('&').
      map{|pair| pair.split('=', 2)}
    hash = Hash[array]
    encoded_xml = hash['XML']
    xml = URI.unescape(encoded_xml)
    parsed = Nokogiri::XML(xml)
    parsed.at_css(css).content == expected
  end

  failure_message do |actual|
    "expected url to have '#{expected}' at '#{css}', but it didn't"
  end

  failure_message_when_negated do |actual|
    "expected url not to have '#{expected}' at '#{css}', but it did"
  end
end

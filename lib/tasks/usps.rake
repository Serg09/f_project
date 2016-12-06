namespace :usps do
  desc 'Get a rate quote'
  task rate: :environment do
    data = NokoGiri::HTML::DocumentParser.parse <<-XML
    <RateV4Request USERID='dgknghtcs'>
      <Package>
        <Service />
        <ZipOrigination />
        <ZipDestination />
        <Pounds />
        <Ounces />
        <Container />
        <Size />
        <Width />
        <Length />
        <Height />
        <Girth />
      </Package>
    </RateV4Request>
    XML
    data.at_css('Package')['ID'] = '1st'
    puts data.to_xml
  end
end

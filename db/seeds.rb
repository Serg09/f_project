# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

usps = Carrier.find_by(name: 'USPS') || Carrier.create(name: 'USPS')
[
  { abbreviation: 'USPS1P'  , description: 'USPS Priority' },
  { abbreviation: 'USPSBP'  , description: 'USPS Media' },
  { abbreviation: 'USPSBPAH', description: 'USPS AK/HI' },
].
  lazy.
  reject{|a| ShipMethod.find_by(abbreviation: a[:abbreviation])}.
  map do |a|
    a.merge carrier_id: usps.id, calculator_class: 'Freight::UspsCalculator'
  end.
  each{|a| ShipMethod.create! a}

ups = Carrier.find_by(name: 'UPS') || Carrier.create(name: 'UPS')
[
  { abbreviation: 'UPS3DAS' , description: 'UPS 3-Day Select Commercial' },
  { abbreviation: 'UPS3DASR', description: 'UPS 3 DAY Residential' },
  { abbreviation: 'UPSGSCNA', description: 'UPS GROUND COMMERCIAL' },
  { abbreviation: 'UPSGSRNA', description: 'UPS GROUND RESIDENTIAL' },
  { abbreviation: 'UPSNDA'  , description: 'UPS NEXT DAY AIR' },
  { abbreviation: 'UPSNDAR' , description: 'UPS NEXT DAY RESIDENTIAL' },
  { abbreviation: 'UPSSDA'  , description: 'UPS 2ND DAY AIR' },
  { abbreviation: 'UPSSDAR' , description: 'UPS 2ND DAY RESIDENTIAL' }
].
  lazy.
  reject{|a| ShipMethod.find_by(abbreviation: a[:abbreviation])}.
  map do |a|
    a.merge carrier_id: ups.id, calculator_class: 'Freight::UpsCalculator'
  end.
  each{|a| ShipMethod.create! a}

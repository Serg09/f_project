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
  { abbreviation: 'USPSBPAH', description: 'USPS AK/HI' }
].
  lazy.
  reject{|a| ShipMethod.find_by(abbreviation: a[:abbreviation])}.
  map do |a|
    a.merge carrier_id: usps.id, calculator_class: 'Freight::UspsCalculator'
  end.
  each{|a| ShipMethod.create! a}

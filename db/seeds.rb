# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

usps = Carrier.find_by(name: 'USPS') || Carrier.create(name: 'USPS')
[
  { abbreviation: 'USPS1P'  , description: 'USPS Priority', active: true },
  { abbreviation: 'USPSBP'  , description: 'USPS Media'   , active: true },
  { abbreviation: 'USPSBPAH', description: 'USPS AK/HI'   , active: false },
].
  lazy.
  reject{|a| ShipMethod.find_by(abbreviation: a[:abbreviation])}.
  map do |a|
    a.merge carrier_id: usps.id, calculator_class: 'Freight::UspsCalculator'
  end.
  each do |a|
    existing = ShipMethod.find_by(abbreviation: a[:abbreviation])
    if existing
      existing.update_attributes a
      existing.save!
    else
      ShipMethod.create! a
    end
  end

ups = Carrier.find_by(name: 'UPS') || Carrier.create(name: 'UPS')
[
  { abbreviation: 'UPS3DAS' , description: 'UPS 3-Day Select Commercial', active: false },
  { abbreviation: 'UPS3DASR', description: 'UPS 3-Day Residential'      , active: false },
  { abbreviation: 'UPSGSCNA', description: 'UPS Ground Commercial'      , active: false },
  { abbreviation: 'UPSGSRNA', description: 'UPS Ground'                 , active: true },
  { abbreviation: 'UPSNDA'  , description: 'UPS Next Day Air'           , active: false },
  { abbreviation: 'UPSNDAR' , description: 'UPS Next Day'               , active: true },
  { abbreviation: 'UPSSDA'  , description: 'UPS 2nd Day Air'            , active: false },
  { abbreviation: 'UPSSDAR' , description: 'UPS 2nd Day'                , active: true }
].
  lazy.
  reject{|a| ShipMethod.find_by(abbreviation: a[:abbreviation])}.
  map do |a|
    a.merge carrier_id: ups.id, calculator_class: 'Freight::UpsCalculator'
  end.
  each do |a|
    existing = ShipMethod.find_by(abbreviation: a[:abbreviation])
    if existing
      existing.update_attributes a
      existing.save!
    else
      ShipMethod.create! a
    end
  end

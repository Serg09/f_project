# == Schema Information
#
# Table name: addresses
#
#  id           :integer          not null, primary key
#  recipient    :string(100)      not null
#  line_1       :string(100)      not null
#  line_2       :string(100)
#  city         :string(100)      not null
#  state        :string(20)       not null
#  postal_code  :string(10)       not null
#  country_code :string(2)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Address < ActiveRecord::Base
  validates_presence_of :line_1, :city, :state, :postal_code, :country_code
  validates_length_of [:line_1, :line_2, :city], maximum: 100
  validates_length_of :state, maximum: 20
  validates_length_of :postal_code, maximum: 10
  validates_length_of :country_code, maximum: 2
end

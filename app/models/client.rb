# == Schema Information
#
# Table name: clients
#
#  id           :integer          not null, primary key
#  name         :string(100)      not null
#  abbreviation :string(5)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Client < ActiveRecord::Base
  validates_presence_of :name, :abbreviation
  validates_length_of :name, maximum: 100
  validates_length_of :abbreviation, maximum: 5
  validates_uniqueness_of [:name, :abbreviation]
end

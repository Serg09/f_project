# == Schema Information
#
# Table name: carriers
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Carrier < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :name, maximum: 100
  validates_uniqueness_of :name
end

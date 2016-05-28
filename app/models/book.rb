# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  isbn       :string(13)       not null
#  title      :string(250)      not null
#  format     :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Book < ActiveRecord::Base
  has_many :identifiers, class_name: 'BookIdentifier'

  validates_presence_of :isbn, :title, :format
  validates_length_of :isbn, maximum: 13
  validates_length_of :title, maximum: 250
  validates_length_of :format, maximum: 100
end

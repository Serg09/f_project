class Book < ActiveRecord::Base
  validates_presence_of :isbn, :title, :format
  validates_length_of :isbn, maximum: 13
  validates_length_of :title, maximum: 250
  validates_length_of :format, maximum: 100
end

# == Schema Information
#
# Table name: book_identifiers
#
#  id         :integer          not null, primary key
#  client_id  :integer          not null
#  book_id    :integer          not null
#  code       :string(20)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BookIdentifier < ActiveRecord::Base
  belongs_to :client
  belongs_to :book

  validates_presence_of :client_id, :book_id, :code
  validates_length_of :code, maximum: 20
end

# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  source     :string
#  filename   :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Document < ActiveRecord::Base
  validates_presence_of :source, :filename, :content
end

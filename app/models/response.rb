# == Schema Information
#
# Table name: responses
#
#  id         :integer          not null, primary key
#  payment_id :integer          not null
#  status     :string           not null
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Response < ActiveRecord::Base
  belongs_to :payment

  validates_presence_of :payment_id, :status, :content
end

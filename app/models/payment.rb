# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  order_id     :integer          not null
#  amount       :decimal(9, 2)    not null
#  state        :string(20)       not null
#  external_id  :string(100)
#  external_fee :decimal(9, 2)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Payment < ActiveRecord::Base
  belongs_to :order

  validates_presence_of :order_id, :amount
  validates_numericality_of :amount, greater_than: 0, if: :amount
  validates_length_of :external_id, maximum: 100
end

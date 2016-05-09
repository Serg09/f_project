require 'rails_helper'

RSpec.describe Order, type: :model do
  let (:attributes) { FactoryGirl.attributes_for(:order) }

  it 'can be created from valid attributes' do
    order = Order.new attributes
    expect(order).to be_valid
  end

  describe '#customer_name' do
    it 'is required' do
      order = Order.new attributes.except(:customer_name)
      expect(order).to have_at_least(1).error_on :customer_name
    end
  end
end

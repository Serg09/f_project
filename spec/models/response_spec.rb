require 'rails_helper'

RSpec.describe Response, type: :model do
  let (:payment) { FactoryGirl.create(:payment) }
  let (:attributes) do
    {
      payment_id: payment.id,
      status: 'approved',
      content: 'this is the stufff'
    }
  end

  it 'can be created from valid attributes' do
    response = Response.new attributes
    expect(response).to be_valid
  end

  describe '#payment_id' do
    it 'is required' do
      response = Response.new attributes.except(:payment_id)
      expect(response).to have(1).error_on(:payment_id)
    end
  end

  describe '#status' do
    it 'is required' do
      response = Response.new attributes.except(:status)
      expect(response).to have(1).error_on(:status)
    end
  end

  describe '#content' do
    it 'is required' do
      response = Response.new attributes.except(:content)
      expect(response).to have(1).error_on(:content)
    end
  end
end

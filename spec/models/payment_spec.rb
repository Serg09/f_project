require 'rails_helper'

RSpec.describe Payment, type: :model do
  let (:order) { FactoryGirl.create(:order) }
  let (:attributes) do
    {
      order_id: order.id,
      amount: 100
    }
  end
  let (:nonce) { Faker::Number.hexadecimal(10) }

  it 'can be created from valid attributes' do
    payment = Payment.new attributes
    expect(payment).to be_valid
  end

  describe '#order_id' do
    it 'is required' do
      payment = Payment.new attributes.except(:order_id)
      expect(payment).to have(1).error_on :order_id
    end
  end

  describe '#amount' do
    it 'is required' do
      payment = Payment.new attributes.except(:amount)
      expect(payment).to have(1).error_on :amount
    end

    it 'must be greater than zero' do
      payment = Payment.new attributes.merge(amount: -1)
      expect(payment).to have(1).error_on :amount
    end
  end

  describe '#external_id' do
    it 'cannot be more than 100 characters' do
      payment = Payment.new attributes.merge(external_id: 'x' * 101)
      expect(payment).to have(1).error_on :external_id
    end
  end

  shared_examples_for 'an executable payment' do
    describe '#execute' do
      context 'on success' do

        let (:external_id) { Faker::Number.hexadecimal(12) }

        before do
          allow(Braintree::Transaction).to \
            receive(:sale).
            and_return(double('result', success?: true, id: external_id))
        end

        it 'changes the state to "approved"' do
          expect do
            payment.execute! nonce
          end.to change(payment, :state).to('approved')
        end

        it 'sets the #external_id' do
          expect do
            payment.execute! nonce
          end.to change(payment, :external_id).to external_id
        end

        it 'sets the #external_fee' do
          expect do
            payment.execute! nonce
          end.to change(payment, :external_fee).to 3.20
        end
      end
    end
  end

  shared_examples_for 'an unexecutable payment' do
    describe '#execute' do
      it 'does not change the state'
      it 'does not change the #external_id'
      it 'does not change the #external_fee'
    end
  end

  shared_examples_for 'a refundable payment' do
    describe '#refund' do
      it 'changes the state to "refunded"'
      it 'reduces the external fee'
    end
  end

  shared_examples_for 'an unrefundable payment' do
    describe '#refund' do
      it 'does not change the state'
      it 'does not change the fee'
    end
  end

  context 'when pending' do
    it_behaves_like 'an executable payment' do
      let (:payment) { FactoryGirl.create(:pending_payment, amount: 100) }
    end
    it_behaves_like 'an unrefundable payment' do
      let (:payment) { FactoryGirl.create(:pending_payment) }
    end
  end

  context 'when approved' do
    it_behaves_like 'an unexecutable payment' do
      let (:payment) { FactoryGirl.create(:approved_payment) }
    end
    it_behaves_like 'a refundable payment'
  end

  context 'when completed' do
    it_behaves_like 'an unexecutable payment'
  end

  context 'when failed' do
    it_behaves_like 'an unrefundable payment'
  end

  context 'when refunded' do
    it_behaves_like 'an unexecutable payment'
    it_behaves_like 'an unrefundable payment'
  end
end

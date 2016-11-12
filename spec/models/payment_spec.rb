require 'rails_helper'

RSpec.describe Payment, type: :model do
  let (:order) { FactoryGirl.create(:order) }
  let (:attributes) do
    {
      order_id: order.id,
      amount: 100
    }
  end
  let (:provider_id) { Faker::Number.hexadecimal(12) }
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
        before do
          allow(Braintree::Transaction).to \
            receive(:sale).
            and_return(payment_provider_response('approved', id: provider_id))
        end

        it 'changes the state to "approved"' do
          expect do
            payment.execute! nonce
          end.to change(payment, :state).to('approved')
        end

        it 'sets the #external_id' do
          if payment.pending?
            expect do
              payment.execute! nonce
            end.to change(payment, :external_id).to provider_id
          end
        end

        it 'sets the #external_fee' do
          if payment.pending?
            expect do
              payment.execute! nonce
            end.to change(payment, :external_fee).to 3.20
          end
        end

        it 'creates a response record' do
          expect do
            payment.execute! nonce
          end.to change(payment.responses, :count).by(1)
        end
      end

      context 'on failure' do
        before do
          allow(Braintree::Transaction).to \
            receive(:sale).
            and_return(payment_provider_response('no_dice'))
        end

        it 'changes the state to "failed"' do
          unless payment.failed?
            expect do
              payment.execute!(nonce)
            end.to change(payment, :state).to('failed')
          end
        end

        it 'does not change the #external_fee' do
          expect do
            payment.execute!(nonce)
          end.not_to change(payment, :external_fee)
        end

        it 'creates a transaction record' do
          expect do
            payment.execute! nonce
          end.to change(payment.responses, :count).by(1)
        end
      end

      context 'on error' do
        before do
          allow(Braintree::Transaction).to \
            receive(:sale).
            and_raise('Induced exception')
        end

        it 'does not change the state' do
          expect do
            payment.execute!(nonce)
          end.not_to change(payment, :state)
        end

        it 'does not set the #external_id' do
          expect do
            payment.execute!(nonce)
          end.not_to change(payment, :external_id)
        end

        it 'does not set the #external_fee' do
          expect do
            payment.execute!(nonce)
          end.not_to change(payment, :external_fee)
        end

        it 'does not create a transaction record' do
          expect do
            payment.execute!(nonce)
          end.not_to change(Response, :count)
        end
      end
    end
  end

  shared_examples_for 'an unexecutable payment' do
    describe '#execute' do
      it 'does not change the state' do
        expect do
          payment.execute!(nonce)
        end.not_to change(payment, :state)
      end

      it 'does not change the #external_id' do
        expect do
          payment.execute!(nonce)
        end.not_to change(payment, :external_id)
      end

      it 'does not change the #external_fee' do
        expect do
          payment.execute!(nonce)
        end.not_to change(payment, :external_fee)
      end

      it 'does not call the provider' do
        expect(Braintree::Transaction).not_to \
          receive(:sale)
        payment.execute!(nonce)
      end
    end
  end

  shared_examples_for 'a refundable payment' do
    before do
      expect(Braintree::Transaction).to \
        receive(:find).
        with(payment.external_id).
        and_return(double('payment', status: 'settled'))
    end

    describe '#refund' do
      context 'on success' do
        before do
          expect(Braintree::Transaction).to \
            receive(:refund).
            and_return(double('result', success?: true,
                                        status: 'refunded'))
        end

        it 'changes the state to "refunded"' do
          expect do
            payment.refund!
          end.to change(payment, :state).to 'refunded'
        end

        it 'reduces the external fee' do
          expect do
            payment.refund!
          end.to change(payment, :external_fee).to 0.30
        end

        it 'creates a transaction record' do
          expect do
            payment.refund!
          end.to change(payment.responses, :count).by(1)
        end
      end

      context 'on failure' do
        before do
          expect(Braintree::Transaction).to \
            receive(:refund).
            and_return(double('result', success?: false,
                                        status: 'no_dice'))
        end

        it 'does not change the state' do
          expect do
            payment.refund!
          end.not_to change(payment, :state)
        end

        it 'does not change the external fee' do
          expect do
            payment.refund!
          end.not_to change(payment, :external_fee)
        end

        it 'creates a response record' do
          expect do
            payment.refund!
          end.to change(payment.responses, :count).by(1)
        end
      end

      context 'on error' do
        before do
          expect(Braintree::Transaction).to \
            receive(:refund).
            and_raise('Induced error')
        end

        it 'does not change the state' do
          expect do
            payment.refund!
          end.not_to change(payment, :state)
        end

        it 'does not change the external fee' do
          expect do
            payment.refund!
          end.not_to change(payment, :external_fee)
        end

        it 'does not create a response record' do
          expect do
            payment.refund!
          end.not_to change(Response, :count)
        end
      end
    end
  end

  shared_examples_for 'an unrefundable payment' do
    describe '#refund' do
      it 'does not change the state' do
        expect do
          payment.refund!
        end.not_to change(payment, :state)
      end

      it 'does not change the fee' do
        expect do
          payment.refund!
        end.not_to change(payment, :external_fee)
      end

      it 'does not call the provider' do
        expect(Braintree::Transaction).not_to \
          receive(:find)
        expect(Braintree::Transaction).not_to \
          receive(:refund)
      end
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
    it_behaves_like 'a refundable payment' do
      let (:payment) { FactoryGirl.create(:approved_payment) }
    end

    describe 'as_json' do
      let (:json) { FactoryGirl.create(:approved_payment).as_json }
      it 'includes the cc last 4' do
        expect(json).to include('last_four' => '1111')
      end

      it 'includes the cc type' do
        expect(json).to include('credit_card_type' => 'Visa')
      end

      it 'includes the cc type image url' do
        expect(json).to include('credit_card_image_url' => 'https://assets.braintreegateway.com/payment_method_logo/visa.png?environment=sandbox')
      end
    end
  end

  context 'when completed' do
    it_behaves_like 'an unexecutable payment' do
      let (:payment) { FactoryGirl.create(:completed_payment) }
    end

    it_behaves_like 'a refundable payment' do
      let (:payment) { FactoryGirl.create(:completed_payment) }
    end
  end

  context 'when failed' do
    it_behaves_like 'an executable payment' do
      let (:payment) { FactoryGirl.create(:failed_payment, amount: 100) }
    end

    it_behaves_like 'an unrefundable payment' do
      let (:payment) { FactoryGirl.create(:failed_payment, amount: 100) }
    end
  end

  context 'when refunded' do
    it_behaves_like 'an unexecutable payment' do
      let (:payment) { FactoryGirl.create(:refunded_payment) }
    end

    it_behaves_like 'an unrefundable payment' do
      let (:payment) { FactoryGirl.create(:refunded_payment) }
    end
  end
end

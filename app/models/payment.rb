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
  include AASM

  belongs_to :order

  validates_presence_of :order_id, :amount
  validates_numericality_of :amount, greater_than: 0, if: :amount

  validates_length_of :external_id, maximum: 100

  aasm(:state, whiny_transitions: false) do
    state :pending, initial: true
    state :approved
    state :completed
    state :failed
    state :refunded

    event :execute do
      transitions from: [:failed, :pending], to: :approved, if: :_execute
      transitions from: :pending, to: :failed, unless: :provider_error
    end

    event :refund do
      transitions from: [:approved, :completed], to: :refunded, if: :_refund
    end
  end

  private

  attr_accessor :provider_error

  def calculate_fee
    return nil unless amount
    (amount * 0.029) + 0.30
  end

  def _execute(nonce)
    result = Braintree::Transaction.sale amount: amount,
                                         payment_method_nonce: nonce,
                                         options: {
                                           submit_for_settlement: true
                                         }
    # TODO Save the response
    self.external_id ||= result.id
    if result.success?
      self.external_fee = calculate_fee
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Error executing payment #{inspect}: #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    self.provider_error = e
    false
  end

  def _refund
    payment = Braintree::Transaction.find(external_id)
    result = if %w(settled settling).include?(payment.status)
               Braintree::Transaction.refund(external_id)
             elsif %w(authorized submitted_for_settlement).include?(payment.status)
               Braintree::Transaction.void(external_id)
             end

    if result.success?
      self.external_fee = 0.30 # Braintree keeps the $0.30 on a refund
      self.state = 'refunded'
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Error refunding payment #{inspect}: #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    self.provider_error = e
    false
  end
end

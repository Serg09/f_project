class Api::V1::PaymentsController < Api::V1::BaseController
  before_action :load_order, only: [:create]

  def token
    render json: {token: Braintree::ClientToken.generate}
  end

  def create
    authorize! :update, @order
    payment = @order.payments.new amount: @order.total
    payment.save!
    payment.execute! params[:payment][:nonce]
    if payment.approved?
      render json: payment
    else
      render json: {message: 'The payment was not approved by the provider.'}, status: :unprocessable_entity
    end
  end

  private

  def load_order
    @order = Order.find(params[:order_id])
  end
end

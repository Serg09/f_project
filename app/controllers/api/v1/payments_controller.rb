class Api::V1::PaymentsController < Api::V1::BaseController
  def token
    render json: {token: Braintree::ClientToken.generate}
  end
end

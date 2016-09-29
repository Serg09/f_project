class Api::V1::OrdersController < Api::V1::BaseController
  def index
    render json: current_client.orders
  end
end

class Api::V1::OrdersController < Api::V1::BaseController
  def index
    render json: Order.all
  end
end

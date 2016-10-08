class Api::V1::OrderItemsController < Api::V1::BaseController
  before_action :load_order, only: [:index]

  def index
    render json: @order.items
  end

  private

  def load_order
    @order = current_client.orders.find params[:order_id]
  end
end

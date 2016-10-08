class Api::V1::OrderItemsController < Api::V1::BaseController
  before_action :load_order, only: [:index, :create]

  def index
    render json: @order.items
  end

  def create
    item = @order.add_item params[:item][:sku], params[:item][:quantity] || 1
    render json: item.as_json(methods: :extended_price)
  end

  private

  def load_order
    @order = current_client.orders.find params[:order_id]
  end
end

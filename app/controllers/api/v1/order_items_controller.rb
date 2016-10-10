class Api::V1::OrderItemsController < Api::V1::BaseController
  before_action :load_order, only: [:index, :create]
  before_action :load_item, only: [:update]

  def index
    render json: @order.items
  end

  def create
    item = @order.add_item params[:item][:sku], params[:item][:quantity] || 1
    render json: item.as_json(methods: :extended_price)
  end

  def update
    authorize! :update, @order_item
    @order_item.update_attributes quantity: params[:item][:quantity]
    @order_item.save
    render json: @order_item
  end

  private

  def load_order
    @order = current_client.orders.find params[:order_id]
  end

  def load_item
    @order_item = OrderItem.find(params[:id])
  end
end

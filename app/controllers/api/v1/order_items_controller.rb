class Api::V1::OrderItemsController < Api::V1::BaseController
  before_action :load_order, only: [:index, :create]
  before_action :load_item, only: [:update, :destroy]
  before_action :validate_order_state!, except: [:index]

  def index
    authorize! :show, @order
    render json: @order.items
  end

  def create
    authorize! :update, @order
    item = @order.add_item params[:item][:sku], params[:item][:quantity] || 1
    render json: item.as_json(methods: :extended_price)
  end

  def update
    authorize! :update, @order_item
    @order_item.update_attributes quantity: params[:item][:quantity]
    @order_item.save
    render json: @order_item
  end

  def destroy
    authorize! :destroy, @order_item
    @order_item.destroy
    render json: @order_item
  end

  private

  def load_order
    @order = Order.find(params[:order_id])
  end

  def load_item
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
  end

  def validate_order_state!
    unless @order.incipient?
      raise InvalidState.new('The order cannot be modified in its current state.')
    end
  end
end

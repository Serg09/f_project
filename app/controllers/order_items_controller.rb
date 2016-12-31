class OrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_order, only: [:new, :create]
  before_action :load_order_item, only: [:edit, :update, :destroy]
  before_action :ensure_order_can_be_edited!, only: [:new, :create, :edit, :update, :destroy]

  respond_to :html

  def new
    @order_item = @order.items.new
  end

  def create
    @order_item = @order.add_item order_item_params[:sku], order_item_params[:quantity]
    flash[:notice] = 'The order item was created successfully.' if @order_item.save
    @order.update_freight_charge!
    respond_with @order_item, location: edit_order_path(@order_item.order_id)
  end

  def edit
  end

  def update
    @order_item.update_attributes order_item_params
    flash[:notice] = 'The order item was updated successfully.' if @order_item.save
    @order_item.order.update_freight_charge!
    respond_with @order_item, location: edit_order_path(@order_item.order_id)
  end

  def destroy
    flash[:notice] = 'The order item was removed successfully.' if @order_item.destroy
    respond_with @order_item, location: edit_order_path(@order_item.order_id)
  end

  private

  def ensure_order_can_be_edited!
    unless can? :update, @order
      redirect_to order_path(@order), alert: 'This order cannot be edited.'
    end
  end

  def load_order
    @order = Order.find(params[:order_id])
  end

  def load_order_item
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
  end

  def order_item_params
    params.require(:order_item).permit(:sku, :quantity)
  end
end

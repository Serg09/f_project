class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.
      by_status(params[:status]).
      by_order_date.paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
  end

  def create
    @order = Order.new order_params
    flash[:notice] = 'The order was created successfuly.' if @order.save
    respond_with @order, location: orders_path
  end

  def edit
  end

  def update
  end

  def destroy
    if can? :destroy, @order
      flash[:notice] = 'The order was removed successfully.' if @order.delete
      respond_with @order, location: orders_path
    else
      redirect_to order_path(@order), alert: 'This order cannot be removed'
    end
  end

  private

  def load_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:order_date,
                                  :client_id,
                                  :customer_name,
                                  :customer_email,
                                  :telephone)
  end
end

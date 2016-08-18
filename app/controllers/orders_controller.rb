class OrdersController < ApplicationController
  respond_to :html

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
    flash[:notice] = 'The order was created successfuly.' if create_order
    respond_with @order, location: orders_path
  end

  def edit
    unless can? :update, @order
      redirect_to order_path(@order), alert: 'This order cannot be edited.'
    end
  end

  def update
    if can? :update, @order
      @order.update_attributes order_params
      flash[:notice] = 'The order was updated successfully.' if @order.save
      respond_with @order, location: orders_path
    else
      redirect_to order_path(@order), alert: 'This order cannot be edited.'
    end
  end

  def destroy
    if can? :destroy, @order
      flash[:notice] = 'The order was removed successfully.' if @order.delete
      respond_with @order, location: orders_path
    else
      redirect_to order_path(@order), alert: 'This order cannot be removed.'
    end
  end

  private

  def create_order
    Order.transaction do
      @address = Address.new shipping_address_params
      @order = Order.new order_params.merge(shipping_address: @address)
      if @address.save && @order.save
        return true
      else
        raise ActiveRecord::Rollback
      end
    end
    false
  end

  def load_order
    @order = Order.find(params[:id])
  end

  def shipping_address_params
    params.require(:shipping_address).
      permit(:line_1,
             :line_2,
             :city,
             :state,
             :postal_code,
             :country_code).
      merge(recipient: params[:order][:customer_name])
  end

  def order_params
    params.require(:order).
      permit(:order_date,
             :client_id,
             :client_order_id,
             :customer_name,
             :customer_email,
             :telephone).
      tap do |attr|
        attr[:order_date] = Date.strptime(attr[:order_date], '%m/%d/%Y')
      end
  end
end

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
    @order = Order.new order_date: Date.today
    @shipping_address = Address.new
  end

  def create
    if create_order
      flash[:notice] = 'The order was created successfully.'
      respond_with @order, location: orders_path(status: :new)
    else
      # respond_with doesn't seem to work with nested objects
      render :new
    end
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
      @shipping_address = Address.new shipping_address_params
      @order = Order.new order_params.merge(shipping_address: @shipping_address)
      if @shipping_address.save && @order.save
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
        if attr[:order_date].present?
          attr[:order_date] = Chronic.parse(attr[:order_date])
        end
      end
  end
end

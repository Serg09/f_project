class OrdersController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!
  before_filter :load_order, except: [:index, :new, :create, :export_csv]

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
      respond_with @order, location: orders_path(status: :incipient)
    else
      # respond_with doesn't seem to work with nested objects
      render :new
    end
  end

  def edit
    unless can? :update, @order
      redirect_to order_path(@order), alert: 'This order cannot be edited.'
    end
    @shipping_address = @order.shipping_address || @order.build_shipping_address
  end

  def update
    if can? :update, @order
      @order.update_attributes order_params
      if params[:shipping_address]
        if @order.shipping_address_id
          @order.shipping_address.update_attributes shipping_address_params
          @order.shipping_address.save!
        else
          shipping_address = Address.new shipping_address_params
          shipping_address.save!

          @order.shipping_address = shipping_address
        end
      end
      if @order.save
        flash[:notice] = 'The order was updated successfully.'
        @order.update_freight_charge!
      end
      respond_with @order, location: orders_path(status: :incipient)
    else
      redirect_to order_path(@order), alert: 'This order cannot be edited.'
    end
  end

  def destroy
    if can? :destroy, @order
      flash[:notice] = 'The order was removed successfully.' if @order.delete
      respond_with @order, location: orders_path(status: :incipient)
    else
      redirect_to order_path(@order), alert: 'This order cannot be removed.'
    end
  end

  def submit
    submitted = @order.submit!
    respond_with @order do |format|
      format.html do
        if submitted
          redirect_to orders_path(status: :submitted), notice: 'The order was submitted successfully.'
        else
          redirect_to order_path(@order), alert: 'The order could not be submitted.'
        end
      end
    end
  end

  def export
    Resque.enqueue ExportProcessor, order_id: @order.id
    exported = @order.export!
    respond_with @order do |format|
      format.html do
        if exported
          redirect_to orders_path(status: :exporting), notice: 'The order has been marked for export.'
        else
          redirect_to order_path(@order), alert: 'The order could not be exported.'
        end
      end
    end
  end

  def export_csv
    orders = Order.find(params[:order_ids].split(','))
    exporter = OrderCsvExporter.new(orders)
    render text: exporter.content, content_type: 'text/csv'
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
             :telephone,
             :ship_method_id).
      tap do |attr|
        if attr[:order_date].present?
          attr[:order_date] = Chronic.parse(attr[:order_date])
        end
      end
  end
end

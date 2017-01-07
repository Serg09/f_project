class Api::V1::OrdersController < Api::V1::BaseController
  before_action :load_order, only: [:show, :submit, :update]

  def index
    render json: current_client.orders
  end

  def create
    order = Order.create(order_params)
    if params[:shipping_address]
      shipping_address = Address.new shipping_address_params
      shipping_address.save
      order.shipping_address = shipping_address
    end
    if order.save
      render json: order
    else
      render json: {errors: order.errors.full_messages}, status: 400
    end
  end

  def show
    authorize! :show, @order
    render json: order_json
  end

  def update
    authorize! :update, @order
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
    @order.save!
    @order.update_freight_charge!
    render json: order_json
  end

  def submit
    authorize! :update, @order
    if !@order.incipient?
      render json: [], status: :unprocessable_entity
    elsif @order.submit!
      OrderMailer.purchase_confirmation(@order).deliver_now
      render json: @order.as_json(include: {shipping_address: {}, items: {methods: [:extended_price]}})
    else
      render json: {error: "Unable to submit the order."}, status: :internal_server_error
    end
  end

  private

  def load_order
    @order = Order.find(params[:id])
  end

  def order_json
    @order.as_json(include: [
      :shipping_address,
      items: {methods: [:extended_price, :standard_item?]}
    ])
  end

  def order_params
    defaults = {
      client_id: current_client.id,
      order_date: Date.today
    }
    if params[:order].present?
      params.require(:order).permit(:customer_name,
                                    :telephone,
                                    :customer_email,
                                    :delivery_email,
                                    :ship_method_id).merge(defaults)
    else
      defaults
    end
  end

  def shipping_address_params
    params.require(:shipping_address).permit(:recipient,
                                             :line_1,
                                             :line_2,
                                             :city,
                                             :state,
                                             :postal_code,
                                             :country_code)
  end
end

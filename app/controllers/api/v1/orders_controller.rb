class Api::V1::OrdersController < Api::V1::BaseController
  before_action :load_order, only: [:show, :submit]

  def index
    render json: current_client.orders
  end

  def create
    order = Order.create(order_params)
    if order.save
      render json: order
    else
      render json: {errors: order.errors.full_messages}, status: 400
    end
  end

  def show
    authorize! :show, @order
    render json: @order.as_json(include: {items: {methods: [:extended_price]}})
  end

  def submit
    authorize! :update, @order
    if !@order.incipient?
      render json: [], status: :unprocessable_entity
    elsif @order.submit!
      render json: @order.as_json(include: {items: {methods: [:extended_price]}})
    else
      render json: {error: "Unable to submit the order."}
    end
  end

  private

  def load_order
    @order = Order.find(params[:id])
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
                                    :ship_method_id,
                                    shipping_address_attributes: [
                                      :recipient,
                                      :line_1,
                                      :line_2,
                                      :city,
                                      :state,
                                      :postal_code,
                                      :country_code
                                    ]).merge(defaults)
    else
      defaults
    end
  end
end

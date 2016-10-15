class Api::V1::OrdersController < Api::V1::BaseController
  def index
    render json: current_client.orders
  end

  def create
    order = Order.create(order_params)
    order.save
    render json: order
  end

  private

  def order_params
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
                                  ]).merge(
                                    client_id: current_client.id,
                                    order_date: Date.today
                                  )
  end
end

class OrdersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @orders = Order.by_order_date.paginate(page: params[:page], per_page: 10)
  end

  def show
  end
end

class OrdersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @orders = Order.by_order_date
  end

  def show
  end
end

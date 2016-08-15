class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_order, only: [:show]

  def index
    @orders = Order.
      by_status(params[:status]).
      by_order_date.paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  private

  def load_order
    @order = Order.find(params[:id])
  end
end

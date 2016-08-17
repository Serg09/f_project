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

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def load_order
    @order = Order.find(params[:id])
  end
end

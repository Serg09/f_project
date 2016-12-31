class ConfirmationsController < ApplicationController
  def show
    @order = Order.where(['confirmation like ?', params[:id]]).first
  end
end

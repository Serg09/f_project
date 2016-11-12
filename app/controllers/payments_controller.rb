class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_payment, only: [:show]

  def index
  end

  def show
  end

  private

  def load_payment
    @payment = Payment.find(params[:id])
  end
end

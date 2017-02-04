class ShipmentsController < ApplicationController
  respond_to :html

  before_action :authenticate_user!
  before_action :load_order, only: [:index, :new, :create]

  def index
    @shipments = @order.shipments
  end

  def new
    @shipment = @order.shipments.new ship_date: Date.today
  end

  def create
    @shipment = @order.shipments.new shipment_params
    flash[:notice] = 'The shipment was created successfully.' if @shipment.save
    respond_with @shipment, location: shipment_shipment_items_path(@shipment)
  end

  private

  def load_order
    @order = Order.find(params[:order_id])
  end

  def shipment_params
    params.
      require(:shipment).
      permit(:external_id,
             :ship_date,
             :weight,
             :quantity,
             :freight_charge,
             :handling_charge).tap do |attributes|
               attributes[:ship_date] = Chronic.parse(attributes[:ship_date])
             end
  end
end

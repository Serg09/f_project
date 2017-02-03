class ShipmentItemsController < ApplicationController
  respond_to :html

  before_action :authenticate_user!
  before_action :load_shipment, only: [:index, :new, :create]

  def index
  end

  def new
    @shipment_item = @shipment.items.new
  end

  def create
    @shipment_item = @shipment.items.new shipment_params
    flash[:notice] = "The shipment item was created successfully." if @shipment_item.save
    respond_with @shipment_item, location: shipment_shipment_items_path(@shipment)
  end

  private

  def load_shipment
    @shipment = Shipment.find(params[:shipment_id])
  end

  def shipment_params
    params.require(:shipment_item).permit(:order_item_id,
                                          :shipped_quantity,
                                          :external_line_no,
                                          :cancel_code,
                                          :cancel_reason)
  end
end

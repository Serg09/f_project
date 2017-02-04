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
    @shipment_item.save
    set_flash
    respond_with @shipment_item, location: create_redirect_path
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

  def create_redirect_path
    if @shipment.order.shipped?
      order_path(@shipment.order_id)
    else
      shipment_shipment_items_path(@shipment)
    end
  end

  def set_flash
    return unless @shipment_item.persisted?
    if @shipment_item.order_item.too_many_items_shipped?
      flash[:warning] = "The shipment item was created successfully, but more items were shipped than were ordered."
    else
      flash[:notice] = "The shipment item was created successfully."
    end
  end
end

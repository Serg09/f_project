class ShipmentItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_shipment, only: [:index, :new, :create]

  def index
  end

  def new
    @shipment_item = @shipment.items.new
  end

  private

  def load_shipment
    @shipment = Shipment.find(params[:shipment_id])
  end
end

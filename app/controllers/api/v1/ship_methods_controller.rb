class Api::V1::ShipMethodsController < Api::V1::BaseController
  def index
    render json: ShipMethod.all.map{|sm| sm.as_json(except: :calculator_class)}
  end
end

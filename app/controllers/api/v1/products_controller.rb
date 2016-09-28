class Api::V1::ProductsController < Api::V1::BaseController
  def index
    render json: Product.all
  end
end

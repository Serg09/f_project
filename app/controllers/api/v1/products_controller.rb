class Api::V1::ProductsController < Api::V1::BaseController
  before_action :load_product, only: [:show]

  def index
    render json: Product.all
  end

  def show
    render json: @product
  end

  private

  def load_product
    @product = params[:sku].present? ?
      Product.find_by(sku: params[:sku]) :
      Product.find(params[:id])
  end
end

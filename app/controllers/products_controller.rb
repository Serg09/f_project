class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_product, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
  end

  def show
  end

  def new
  end

  def create
    @product = Product.new product_params
    flash[:notice] = "The product was created successfully." if @product.save
    respond_with @product, location: products_path
  end

  def edit
  end

  def update
    @product.update_attributes product_params
    flash[:notice] = "The product was updated successfully." if @product.save
    respond_with @product, location: products_path
  end

  private

  def load_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:sku, :description, :price)
  end
end

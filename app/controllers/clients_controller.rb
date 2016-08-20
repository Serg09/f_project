class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_client, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @clients = Client.all.paginate page: params[:page]
  end

  def show
  end

  def new
  end

  def create
    @client = Client.new client_params
    flash[:notice] = 'The client was created successfully.' if @client.save
    respond_with @client, location: clients_path
  end

  def edit
  end

  def update
    @client.update_attributes client_params
    flash[:notice] = 'The client was updated successfully.' if @client.save
    respond_with @client, location: clients_path
  end

  def destroy
    flash[:notice] = 'The client was removed successfully.' if @client.destroy
    respond_with @client, location: clients_path
  end

  private

  def client_params
    params.require(:client).permit(:name, :abbreviation)
  end

  def load_client
    @client = Client.find(params[:id])
  end
end

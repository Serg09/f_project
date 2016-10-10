class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :destroy_session
  before_action :authenticate!

  attr_reader :current_client

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {message: 'not found'}, status: 404
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: {message: 'not found'}, status: 404
  end

  def current_ability
    @current_ability ||= ApiAbility.new(current_client)
  end

  private

  def authenticate!
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      @current_client = Client.find_by(auth_token: token)
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: {error: 'Bad credentials'}, status: :unauthorized
  end

  def destroy_session
    request.session_options[:skip] = true
  end
end

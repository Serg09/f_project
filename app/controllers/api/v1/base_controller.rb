class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session,
    if: Proc.new{|c| c.request.format.json?}

  skip_before_action :verify_authenticity_token
  before_action :destroy_session
  before_action :authenticate!

  attr_reader :current_client

  rescue_from StandardError do |exception|
    Rails.logger.warn "rescue_from #{exception.inspect}"
    exception.backtrace.each{|f| Rails.logger.warn "  #{f}"}
    render json: {message: exception.message}, status: :internal_service_error
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {message: 'not found'}, status: :not_found
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: {message: 'not found'}, status: :not_found
  end

  rescue_from InvalidState do |exception|
    render json: {message: exception.message}, status: :conflict
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

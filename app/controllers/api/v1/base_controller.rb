class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :destroy_session
  before_action :authenticate!

  private

  def authenticate!
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      token == "abc123"
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

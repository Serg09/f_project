class Api::V1::OrdersController < Api::V1::BaseController
  before_action :authenticate!

  def index
    render json: Order.all
  end

  protected

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
end

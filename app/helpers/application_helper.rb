module ApplicationHelper
  FLASH_MAP = {
    'notice' => 'success',
    'alert' => 'danger'
  }

  def flash_key_to_alert_class(flash_key)
    "alert-#{FLASH_MAP[flash_key] || flash_key}"
  end

  def show_nav_bar_sign_in_form?
    !(user_signed_in? || request_uri.path == new_user_session_path)
  end

  private 

  def request_uri
    @request_uri ||= URI.parse(request.original_url)
  end
end

module ApplicationHelper
  FLASH_MAP = {
    'notice' => 'success',
    'alert' => 'danger'
  }

  def flash_key_to_alert_class(flash_key)
    "alert-#{FLASH_MAP[flash_key] || flash_key}"
  end

  def format_date(value)
    value.strftime '%-m/%-d/%Y'
  end

  def form_group_class(model, attribute)
    model.errors[attribute].any? ? 'has-error' : nil
  end

  def help_blocks(model, attribute)
    messages = model.errors.full_messages_for(attribute)
    return nil unless messages.any?
    messages.map do |m|
      content_tag :span, m, class: 'help-block'
    end.join('').html_safe
  end

  def show_nav_bar_sign_in_form?
    !(user_signed_in? || request_uri.path == new_user_session_path)
  end

  private 

  def request_uri
    @request_uri ||= URI.parse(request.original_url)
  end
end

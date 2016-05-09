module ApplicationHelper
  FLASH_MAP = {
    'notice' => 'success',
    'alert' => 'danger'
  }

  def flash_key_to_alert_class(flash_key)
    "alert-#{FLASH_MAP[flash_key] || flash_key}"
  end
end

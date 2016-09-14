module LogHelper
  def logger
    @logger ||= Rails.env.test? ?
      Rails.logger :
      Logger.new(STDOUT)
  end
end

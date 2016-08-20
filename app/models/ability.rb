class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can([:update, :destroy], Order){|o| o.updatable?}
  end
end

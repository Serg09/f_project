class ApiAbility
  include CanCan::Ability

  def initialize(client)
    client ||= Client.new

    can :manage, Order, client_id: client.id
    can :manage, OrderItem, order: {client_id: client.id}
  end
end

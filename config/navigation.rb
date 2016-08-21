SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    if user_signed_in?
      primary.item :clients, 'Clients', clients_path
      primary.item :orders, 'Orders', orders_path(status: :incipient) do |orders_item|
        orders_item.dom_class = 'nav nav-tabs'
        Order::STATUSES.each do |status|
          orders_item.item status,
                           status.to_s.capitalize,
                           orders_path(status: status),
                           highlights_on: Regexp.new(status.to_s)
        end
      end
      primary.item :products, 'Products', products_path
      primary.item :sign_out, 'Sign out', destroy_user_session_path, method: :delete
    else
      primary.item :sign_in, 'Sign in', new_user_session_path
    end
  end
end

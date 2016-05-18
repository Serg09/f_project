SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    if user_signed_in?
      primary.item :orders, 'Orders', orders_path do |orders_item|
        orders_item.dom_class = 'nav nav-tabs'
        orders_item.item :unexported, 'Unexported', orders_path(exported: false)
        orders_item.item :exported, 'Exported', orders_path(exported: true)
      end
      primary.item :sign_out, 'Sign out', destroy_user_session_path, method: :delete
    else
      primary.item :sign_in, 'Sign in', new_user_session_path
    end
  end
end

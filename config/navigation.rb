SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    primary.item :sign_in, 'Sign in', new_user_session_path, unless: ->{user_signed_in?}
    primary.item :sign_out, 'Sign out', destroy_user_session_path, method: :delete, if: ->{user_signed_in?}
  end
end

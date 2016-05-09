module NavigationHelpers
  def path_for(page_description)
    case page_description
    when "home" then root_path
    else raise "unrecognized page description \"#{page_description}\"."
    end
  end

  def locator_for(location_description)
    case location_description
    when "navigation" then "#menu"
    when "notification area" then "#notifications"
    when "page title" then "#page-title"
    when "main content" then "#main-content"
    else raise "unrecognized location description \"#{location_description}\"."
    end
  end
end
World(NavigationHelpers)

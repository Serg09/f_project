module NavigationHelpers
  def path_for(page_description)
    case page_description
    when "home" then root_path
    else raise "unrecognized page description \"#{page_description}\"."
    end
  end

  def locator_for(location_description)
    case location_description
    when "menu" then "#menu"
    when "navigation" then "#menu"
    when "secondary menu" then ".secondary-nav"
    when "notification area" then "#notifications"
    when "page title" then "#page-title"
    when "main content" then "#main-content"
    when /(\d(?:st|nd|rd|th)) (.+) row/ then "##{hyphenize($2)}-table tr:nth-child(#{$1.to_i + 1})"
    else raise "unrecognized location description \"#{location_description}\"."
    end
  end

  private

  def hyphenize(words)
    words.gsub(/\s/, "-")
  end
end
World(NavigationHelpers)

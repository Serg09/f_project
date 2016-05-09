class BootstrapNavigationRenderer < SimpleNavigation::Renderer::Base
  def render(item_container)
    return '' if skip_if_empty? and item_container.empty?

    list_content = item_container.items.inject([]) do |list, item|
      list << content_tag(:li, item_content(item), item.html_options.except(:link))
    end.join
    content_tag(:ul, list_content, id: item_container.dom_id, class: list_class(item_container))
  end

  def link_options_for(item)
    result = item.link_html_options || {}
    result[:method] = item.method if item.method
    result.merge!(
      :class => append_css_class(result[:class], 'dropdown-toggle'),
      'data-toggle' => 'dropdown',
      'role' => 'button',
      'aria-haspopup' => 'true'
    ) if is_dropdown_toggle?(item)
    result
  end

  def tag_for(item)
    if item.sub_navigation || !suppress_link?(item)
      link_to(link_content(item), item.url, options_for(item))
    else
      content_tag('span', item.name, link_options_for(item).except(:method))
    end
  end

  private

  def is_dropdown_toggle?(item)
    item.sub_navigation
  end

  def append_css_class(existing_class, additional_class)
    return additional_class unless existing_class

    classes = existing_class.split(/\s+/)
    classes << additional_class
    classes.join(' ')
  end

  def list_class(container)
    case container.level
    when 1 then 'nav navbar-nav'
    when 2 then 'dropdown-menu'
    end
  end

  def list_options(container)
    result = {
      id: container.dom_id,
      class: list_class(container)
    }
    result
  end

  def link_content(item)
    is_dropdown_toggle?(item) ?
      "#{item.name}<span class=\"caret\"></span>".html_safe :
      item.name
  end

  def item_content(item)
    result = tag_for item
    result << render_sub_navigation_for(item) if include_sub_navigation?(item)
    result
  end
end

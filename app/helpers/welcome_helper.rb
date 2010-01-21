module WelcomeHelper

  def link_to_category(category)
    link_to(category.name, category_designs_path(category))
  end

  def categories_links(group)
    group.compact.each do |c|
      haml_tag :li, link_to_category(c)
    end
  end

  def categories_header
    return if all_enabled_categories.blank? || all_enabled_categories.size.zero?

    groups = (all_enabled_categories.size/3).to_i
    groups = 1 if groups.zero?

    all_enabled_categories.in_groups_of(groups).each do |group|
      haml_tag :ul do
        categories_links(group)
      end
    end
  end

  def categories_footer
    all_enabled_categories.in_groups_of(5).each do |group|
      haml_tag(:ul, :class => "list") do
        categories_links(group)
      end
    end
  end

  def select_carousel_link()
    link_to content_tag(:span, _("SELECT")), "#", :class => "blue-btn-sml", :id => "carousel_select_link"
  end
end

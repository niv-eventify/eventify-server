module WelcomeHelper

  # TODO: cache categories

  def link_to_category(category)
    link_to(category.name, category_designs_path(category))
  end

  def categories_links(group)
    group.compact.each do |c|
      haml_tag :li, link_to_category(c)
    end
  end

  def categories_header
    groups = (all_enabled_categories.size/3).to_i
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
end

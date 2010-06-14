module WelcomeHelper

  def link_to_category(category)
    link_to(category.name, category_designs_path(category))
  end

  def categories_links(group)
    group.compact.each do |c|
      haml_tag :li, link_to_category(c), {:class => "#{'last' if c == group.compact.last}"}
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
    counts = all_enabled_categories.count
    counts = 1 if counts.zero?

    groups = counts / 7
    groups += 1 unless (counts % 7).zero?
    all_enabled_categories.in_groups_of(groups).each do |group|
      haml_tag(:ul, :class => "list") do
        categories_links(group)
      end
    end
  end

  def main_box_text
    msg = _("Choose a cool invite, or even upload your own photo. Add event details, with a map and a personal message, and send to all your friends through email, sms and facebook!")
    msg.gsub("\n", "<BR/>")
  end
end

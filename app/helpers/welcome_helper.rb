module WelcomeHelper

  # TODO: cache categories

  def link_to_category(c)
    link_to_function(c.name, "alert('todo')")
  end

  def categories_header
    cats = Category.enabled.all
    groups = (cats.size/3).to_i
    Category.enabled.all.in_groups_of(groups).each do |group|
      haml_tag :ul do
        group.compact.each do |c|
          haml_tag :li, link_to_category(c)
        end
      end
    end
  end

  def categories_footer
    Category.enabled.all.in_groups_of(5).each do |group|
      haml_tag :ul, :class => "list" do
        group.compact.each do |c|
          haml_tag :li, link_to_category(c)
        end
      end
    end
  end
end

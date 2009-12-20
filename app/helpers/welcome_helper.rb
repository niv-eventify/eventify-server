module WelcomeHelper
  def categories_footer
    Category.enabled.all.in_groups_of(5).each do |group|
      haml_tag :ul, :class => "list" do
        group.compact.each do |c|
          haml_tag :li, link_to_function(c.name, "alert('todo')")
        end
      end
    end
  end
end

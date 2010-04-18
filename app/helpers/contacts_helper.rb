module ContactsHelper
  SUBTABS = [
    {:id => :index, :url => "/contacts", :title => N_("contacts tab|All Contacts")},
    {:id => :import, :url => "/contact_importers", :title => N_("contacts tab|Import")},
    {:id => :new, :url => "/contacts/new", :title => N_("contacts tab|Add Contact")}
  ]

  def contacts_navigation(tab_id)
    haml_tag(:div, :class => "nav-bar") do
      haml_tag(:ul) do
        SUBTABS.each do |t|
          haml_tag(:li, :class => (tab_id == t[:id] ? "active" : "")) do
            haml_concat link_to(s_(t[:title]), t[:url])
          end          
        end
      end
    end
  end
end

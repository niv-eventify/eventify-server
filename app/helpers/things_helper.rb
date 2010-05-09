module ThingsHelper
  def new_things_form
    form_remote_for(:thing, @thing ||= Thing.new, :builder => TableFormBuilder::Builder, 
      :url => event_things_path(@event), :html => {:id => "new_thing"},
      :before => "jQuery('#adding_thing').attr('disabled', 'true')") do |f|

      yield(f)

    end
  end

  def link_to_remove_thing(thing)
    link_to_remote "del", :url => event_thing_path(thing.event_id, thing), :method => :delete, 
      :confirm => _("Are you sure?"), :html => {:class => "bin"}, :before => "$('##{dom_id(thing)}').hide()"
  end

  def taking_bar(taking)
    content_tag(:strong, h(taking.guest.name)) + "&nbsp;" + "x&nbsp;#{taking.amount}&nbsp;" + remove_taking_link(taking)
  end

  def remove_taking_link(taking)
    link_to_remote "x", :url => event_taking_path(taking.event_id, taking), :method => :delete, :html => {:class => "taking-remove"},
      :before => "jQuery('##{dom_id(taking)}').remove()"
  end

  def refresh_thing_row(page, thing)
    page << "jQuery('tr##{dom_id(thing)}').replaceWith(#{render(:partial => "things/thing", :object => thing).to_json});"
  end
end

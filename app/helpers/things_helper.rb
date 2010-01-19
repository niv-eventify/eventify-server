module ThingsHelper
  def new_things_form
    form_remote_for(:thing, @thing ||= Thing.new, :builder => TableFormBuilder::Builder, 
      :url => event_things_path(@event), :html => {:id => "new_thing"},
      :before => "jQuery('#adding_thing').attr('disabled', 'true')") do |f|

      yield(f)

    end
  end

  def link_to_remove_thing(event, thing)
    link_to_remote "del", :url => event_thing_path(event, thing), :method => :delete, 
      :confirm => _("Are you sure?"), :html => {:class => "bin"}, :before => "$('##{dom_id(thing)}').hide()"
  end
end

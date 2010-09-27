module RemindersHelper

  def before_units_for_select
    returning([]) do |res|
      Reminder.default_before_units.each do |key, v|
        res << [s_(v), key]
      end
    end
  end

  def reminder_remote_is_active(reminder)
    return unless reminder.reminder_sent_at.nil?
    form_remote_for :reminder, reminder, :url => event_reminder_path(reminder.event_id, reminder), :method => :put do |f|
      haml_concat f.check_box(:is_active, :onchange => "jQuery(this).parents('form').get(0).onsubmit()", :id => "#{dom_id(reminder)}_is_active")
    end
  end

  def rerender_reminders(page)
    page << <<-JAVASCRIPT
      jQuery.nyroModalManual({content: #{render(:partial => 'index').to_json}});
      jQuery(function(){jQuery('a.link_to_add_reminder').nyroModal();});
      jQuery("div.form-col-edit a.edit").click(function(){
        var url = jQuery(this).attr("href");
        show_nyro_loading(function(){jQuery.ajax({url: url, type: "get", dataType:'script'});});
        return false;
      });  
      jQuery('.event-reminders input:checkbox').customCheckbox();
    JAVASCRIPT
  end

end

module RemindersHelper

  def before_units_for_select
    returning([]) do |res|
      Reminder.default_before_units.each do |key, v|
        res << [s_(v), key]
      end
    end
  end

  def reminder_info(reminder)
    res = "#{reminder.before_in_words}"
    res << " "  << s_("reminder|(sent)") unless reminder.reminder_sent_at.nil?
    res
  end

  def reminder_remote_is_active(reminder)
    form_remote_for :reminder, reminder, :url => event_reminder_path(reminder.event_id, reminder), :method => :put do |f|
      haml_concat f.check_box(:is_active, :onchange => "jQuery(this).parents('form').get(0).onsubmit()", :id => "#{dom_id(reminder)}_is_active", :disabled => !reminder.reminder_sent_at.nil?)
    end
  end

  def rerender_reminders(page)
    page << "jQuery('.event-reminders').html(#{render(:partial => "index").to_json});"
    page << "jQuery('.event-reminders input:checkbox').customCheckbox();"
  end

end

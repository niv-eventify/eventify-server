module RemindersHelper

  def before_units_for_select
    returning([]) do |res|
      Reminder.default_before_units.each do |key, v|
        res << [s_(v), key]
      end
    end
  end

  def reminder_info(reminder)
    res = "#{reminder.before_in_words}, #{reminder.whom_to_in_words} #{reminder.by_in_words}"
    res << " "  << s_("reminder|sent") unless reminder.reminder_sent_at.nil?
    res
  end
end

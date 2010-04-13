class RemindersSendToAllGuests < ActiveRecord::Migration
  def self.up
    remove_column :reminders, :to_not_responded
    remove_column :reminders, :to_may_be
    remove_column :reminders, :to_no
    remove_column :reminders, :to_yes
  end

  def self.down
    add_column :reminders, :to_yes, :boolean
    add_column :reminders, :to_no, :boolean
    add_column :reminders, :to_may_be, :boolean
    add_column :reminders, :to_not_responded, :boolean
  end
end

class AddRsvpSummaryScheduler < ActiveRecord::Migration
  def self.up
    add_column :events, :rsvp_summary_send_at, :datetime
    add_column :events, :rsvp_summary_send_every, :integer, :default => 0
    add_index :events, [:starting_at, :rsvp_summary_send_at]
  end

  def self.down
    remove_index :events, [:starting_at, :rsvp_summary_send_at]
    remove_column :events, :rsvp_summary_send_every
    remove_column :events, :rsvp_summary_send_at
  end
end

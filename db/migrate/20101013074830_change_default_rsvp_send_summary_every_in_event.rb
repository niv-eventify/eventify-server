class ChangeDefaultRsvpSendSummaryEveryInEvent < ActiveRecord::Migration
  def self.up
    change_column :events, :rsvp_summary_send_every, :integer, :default => 2
  end

  def self.down
    change_column :events, :rsvp_summary_send_every, :integer, :default => 0
  end
end

class AddCancelledAtToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :canceled_at, :datetime
    remove_index :events, [:starting_at, :rsvp_summary_send_at]
    add_index :events, [:starting_at, :canceled_at, :rsvp_summary_send_at], :name => "start_cancel_summary_sent"
  end

  def self.down
    remove_index :events, :name => "start_cancel_summary_sent"
    add_index :events, [:starting_at, :rsvp_summary_send_at]
    remove_column :events, :canceled_at
  end
end

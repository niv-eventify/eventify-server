class AddSummarySentAtToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :last_summary_sent_at, :datetime
  end

  def self.down
    remove_column :events, :last_summary_sent_at
  end
end

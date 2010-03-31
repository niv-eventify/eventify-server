class AddSummarySendToGuests < ActiveRecord::Migration
  def self.up
    add_column :guests, :summary_email_sent_at, :datetime
  end

  def self.down
    remove_column :guests, :summary_email_sent_at
  end
end

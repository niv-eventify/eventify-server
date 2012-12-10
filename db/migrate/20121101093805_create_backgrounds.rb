class CreateBackgrounds < ActiveRecord::Migration
  def self.up
    #create_table :backgrounds do |t|
    #  t.integer   :event_id
    #  t.string    :rsvp_file_name
    #  t.string    :rsvp_content_type
    #  t.integer   :rsvp_file_size
    #  t.datetime  :rsvp_updated_at
    #
    #  t.timestamps
    #end
  end

  def self.down
    drop_table :backgrounds
  end
end

class AddTzToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :tz, :string, :limit => 128
    ActiveRecord::Base.connection.execute "update events set tz = 'Jerusalem'"
    Event.all.each do |e|
      e.with_time_zone do
        e.starting_at = e.starting_at_before_type_cast
        e.ending_at = e.ending_at_before_type_cast if e.ending_at
        e.save(false)
      end
    end
  end

  def self.down
    remove_column :events, :tz
  end
end

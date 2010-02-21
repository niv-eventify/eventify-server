class AddLanguageToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :language, :string, :limit => 16
    ActiveRecord::Base.connection.execute "update events set language = 'he'"
  end

  def self.down
    remove_column :events, :language
  end
end

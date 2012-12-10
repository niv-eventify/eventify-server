class CreateMovies < ActiveRecord::Migration
  def self.up
    #create_table :movies do |t|
    #  t.integer   :event_id
    #  t.integer   :embedding_provider_id
    #  t.string    :in_site_id
    #  t.timestamps
    #end
  end

  def self.down
    drop_table :movies
  end
end

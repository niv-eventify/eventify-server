class CreateEmbeddingProviders < ActiveRecord::Migration
  def self.up
    #create_table :embedding_providers do |t|
    #  t.string      :name
    #  t.string      :src
    #  t.string      :get_params_for_preview
    #  t.string      :get_params_for_stage2
    #  t.string      :html_attrs_for_preview
    #  t.string      :html_attrs_for_stage2
    #  t.timestamps
    #end
    #EmbeddingProvider.new(:name => "vimeo", :src => "http://player.vimeo.com/video/in_site_id?", :get_params_for_preview => "autoplay=1&api=1", :get_params_for_stage2 => "autoplay=1&api=1", :html_attrs_for_preview => "{:width=>'889', :height=>'563', :frameborder=>'0', :webkitAllowFullScreen=>true, :mozallowfullscreen=>true, :allowFullScreen=>true}", :html_attrs_for_stage2 => "{:width=>'561', :height=>'374', :frameborder=>'0', :webkitAllowFullScreen=>true, :mozallowfullscreen=>true, :allowFullScreen=>true}").save
  end

  def self.down
    drop_table :embedding_providers
  end
end

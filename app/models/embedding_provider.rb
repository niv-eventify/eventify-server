class EmbeddingProvider < ActiveRecord::Base
  attr_accessible :name, :src, :get_params_for_preview, :get_params_for_stage2, :html_attrs_for_preview, :html_attrs_for_stage2

end

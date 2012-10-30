module MoviesHelper
  def get_movie_iframe_preview(movie)
    ep = movie.embedding_provider
    url = ep.src.gsub("in_site_id", movie.in_site_id)
    haml_tag :iframe, ep.html_attrs_for_preview, {:src => "#{url}#{ep.get_params_for_preview}"}.merge(eval(ep.html_attrs_for_preview))
  end

  def get_movie_iframe_stage2(movie)
    ep = movie.embedding_provider
    url = ep.src.gsub("in_site_id", movie.in_site_id)
    haml_tag :iframe, ep.html_attrs_for_stage2, {:src => "#{url}#{ep.get_params_for_stage2}"}.merge(eval(ep.html_attrs_for_stage2))
  end
end

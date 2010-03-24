class RemoteDesignsWillPaginate < DesignsWillPaginate

protected
  def page_link(page, text, attributes = {}, link_attributes = {})
    if same_page = attributes.delete(:same_page)
      page = same_page
    end
    @template.content_tag(:li,
      @template.link_to_remote(text, {:url => url_for(page), :method => :get}, link_attributes), 
      attributes)
  end
end
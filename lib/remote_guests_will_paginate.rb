class RemoteGuestsWillPaginate < DesignsWillPaginate

protected

  def page_link(page, text, attributes = {}, link_attributes = {})
    if same_page = attributes.delete(:same_page)
      page = same_page
    end
    # @template.content_tag(:li, @template.link_to(text, url_for(page), link_attributes), attributes)
    lnk = @template.link_to_remote(text, :url => url_for(page), :method => :get, :html => link_attributes)
    @template.content_tag(:li, lnk, attributes)
  end

end
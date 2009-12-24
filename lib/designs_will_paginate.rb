class DesignsWillPaginate < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

  def to_html
    links = @options[:page_links] ? windowed_links : []

    prev_opts = {
      :class => "first"
    }
    unless @collection.previous_page
      prev_opts[:class] << " disabled"
      prev_opts[:same_page] = 1
    end
    links.unshift(page_link(@collection.previous_page, "prev", prev_opts, :class => "prev"))

    next_opts = {
      :class => "last"
    }
    unless @collection.next_page
      next_opts[:class] << " disabled"
      next_opts[:same_page] = @collection.total_pages
    end
    links.push(page_link(@collection.next_page, "next", next_opts, :class => "next"))

    ul = @template.content_tag(:ul, links.join)

    @template.content_tag(:div, @template.content_tag(:div, @template.content_tag(:div, ul, :class => "pr"), :class =>"pl"), :class => "page-nav")
  end

  def windowed_links
    visible_page_numbers.map do |n|
      page_link(n, n.to_s, (n == current_page ? {:class => "active"} : {}))
    end
  end

protected

  def page_link(page, text, attributes = {}, link_attributes = {})
    if same_page = attributes.delete(:same_page)
      page = same_page
    end
    @template.content_tag(:li, @template.link_to(text, url_for(page), link_attributes), attributes)
  end
end

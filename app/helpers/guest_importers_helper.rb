module GuestImportersHelper
  def render_in_parent(opts)
    haml_tag :html, :xmlns => "http://www.w3.org/1999/xhtml" do
      haml_tag :head do
        haml_tag :meta, :content => "text/html; charset=utf-8", "http-equiv" => "Content-Type"
        haml_tag :meta, "http-equiv" => "X-UA-Compatible", :content => "IE=EmulateIE7"
      end
      haml_tag :body do
        haml_concat javascript_tag("window.parent.jQuery.nyroModalManual({content:#{render(opts).to_json}})")
      end
    end    
  end
end

module GuestImportersHelper
  def render_new_guests_import_form(page)
    page << <<-JAVASCRIPT
      jQuery.nyroModalManual({content: #{render(:partial => @source).to_json}});
      jQuery('li.#{params[:contact_source] || 'gmail'}').addClass('active');
      jQuery('div.#{params[:contact_source] || 'gmail'}_form').show()
    JAVASCRIPT
  end
end

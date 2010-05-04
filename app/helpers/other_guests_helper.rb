module OtherGuestsHelper
  def tab_dom_id
    @tab_dom_id ||= case params[:filter]
    when "no"
      "tab-3"
    when "maybe"
      "tab-2"
    when "not_responded"
      "tab-4"
    else
      "tab-1"
    end
  end
end

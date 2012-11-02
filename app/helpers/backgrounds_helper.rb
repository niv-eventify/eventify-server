module BackgroundsHelper
  def rsvp_background(event)
    haml_tag('img', {:src =>event.backgrounds[0].rsvp.url, :alt => "", :style=>"	width: 100%;
	position: absolute;top: 0;left: 0;"})
  end
end
module BackgroundsHelper
  def rsvp_background(event)
    "body{background-image:url(#{event.backgrounds[0].rsvp.url});}"
  end
end
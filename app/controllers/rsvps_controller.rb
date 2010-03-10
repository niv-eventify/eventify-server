class RsvpsController < InheritedResources::Base
  actions :show, :update

  # guest rsvp page
  def show
  end

  # guest update page
  def update
    @guest.rsvp = Guest.sanitize_rsvp(params[:guest][:rsvp])
    @guest.save
  end  

protected
  def resource
    @guest ||= Guest.find_by_email_token(params[:id]) || (raise ActiveRecord::RecordNotFound)
  end
end

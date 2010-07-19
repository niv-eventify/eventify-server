class SendGridEventsController < InheritedResources::Base
  skip_before_filter :verify_authenticity_token, :only => :create

  def create
    if(params[:event] == 'bounce')
      @bounce = Bounce.new()
      event_id = params[:category].sub("event_", "")
      @bounce.event_id = event_id
      @bounce.guest_id = Guest.find_by_event_id_and_email(event_id, params[:email]).id
      @bounce.status = params[:status]
      @bounce.reason = params[:reason]
      @bounce.save
      render :nothing => true
    end
  end
end

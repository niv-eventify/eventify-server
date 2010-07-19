class SendGridEventsController < InheritedResources::Base
  skip_before_filter :verify_authenticity_token, :only => :create

  def create
    if(params[:event] == 'bounce')
      @bounce = Bounce.new()
      @bounce.event_id = params[:category].sub("event_", "")
      @bounce.email = params[:email]
      @bounce.status = params[:status]
      @bounce.reason = params[:reason]
      @bounce.save
      render :nothing => true
    end
  end
end

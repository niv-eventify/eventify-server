class SendGridEventsController < InheritedResources::Base
  skip_before_filter :verify_authenticity_token, :only => :create

  def create
    case params[:event]
    when 'bounce'
      _create_bounce
    end
    render :nothing => true
  end

protected
  def _create_bounce
    return unless _event_id.to_i > 0

    if event = Event.find(_event_id)
      event.bounce_guest_by_email!(params[:email], params[:status], params[:reason]) if params[:email]
    end
  end

  def _event_id
    @_event_id ||= (params[:category] =~ /event_(\d+)/ && $1)
  end
end

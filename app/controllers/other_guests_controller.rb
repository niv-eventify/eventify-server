class OtherGuestsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "other_guest"

  belongs_to :event, :polymorphic => true
  belongs_to :rsvp, :polymorphic => true
  before_filter :set_columns_count

  actions :index
  respond_to :js

protected

  def collection
    @collection ||= unless params[:query].blank?
      Guest.search(params[:query], :with => {:event_id => parent.id})
    else
      parent.guests.send(rsvp_filter)
    end.paginate(:page => params[:page], :per_page => (params[:per_page] || @columns_count * 6))
  end

  def parent
    @parent ||= params[:event_id] ? current_user.events.find(params[:event_id]) : (Guest.find_by_email_token(params[:rsvp_id]).try(:event) || raise(ActiveRecord::RecordNotFound))
  end

  def set_columns_count
    @columns_count = (params[:columns_count] || 5).to_i
  end

  def rsvp_filter
    case params[:filter]
    when "no"
      :rsvp_no
    when "maybe"
      :rsvp_maybe
    when "not_responded"
      :rsvp_not_responded
    else
      :rsvp_yes
    end
  end
end

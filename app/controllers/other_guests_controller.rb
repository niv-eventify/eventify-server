class OtherGuestsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "other_guest"

  belongs_to :event, :polymorphic => true
  belongs_to :rsvp, :polymorphic => true
  before_filter :set_columns_count

  actions :index
  respond_to :js, :html

  def index
    index! do |success, failure|
      success.html {render :layout => false}
      success.js
    end
  end

protected

  def collection
    return nil if params[:rsvp_id] && !parent.allow_seeing_other_guests?

    return @collection if @collection

    @collection = if !params[:query].blank?
      Guest.search("#{params[:query]}*", :with => {:event_id => parent.id}).paginate(:page => params[:page], :per_page => (params[:per_page] || @columns_count * 6))
    elsif params[:print]
      parent.guests.all
    else
      parent.guests.send(rsvp_filter).paginate(:page => params[:page], :per_page => (params[:per_page] || @columns_count * 6))
    end
  end

  def parent
    @parent ||= params[:event_id] ? event_by_user_or_host : (Guest.find_by_email_token(params[:rsvp_id]).try(:event) || raise(ActiveRecord::RecordNotFound))
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
    when "not_rsvped"
      :rsvp_not_rsvped
    when "not_opened_invite"
      :rsvp_not_opened_invite
    else
      :rsvp_yes
    end
  end
end

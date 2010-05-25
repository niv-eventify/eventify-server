class GuestImportersController < ApplicationController
  before_filter :require_user, :set_event
  layout "guest_import"
  SOURCES = ["email", "csv", "addressbook"]

  def create
    guests_imported = @event.guests.import(selected_contracts)
    flash[:notice] = n_("%d guest imported", "%d guests imported", guests_imported) % guests_imported
    redirect_to event_guests_path(@event)
  end

  def index
    @source = SOURCES.member?(params[:source]) ? params[:source] : raise(ActiveRecord::RecordNotFound)
  end

protected
  def set_event
    @event = current_user.events.find(params[:event_id])
  end

  def selected_contracts
    returning([]) do |res|
      params[:contact].keys.each do |k|
        res << params[:contact][k] if "1" == params[:contact][k][:import]
      end
    end
  end
end

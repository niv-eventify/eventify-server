class GuestImportersController < ApplicationController
  before_filter :require_user, :set_event
  layout "guest_import"
  SOURCES = ["email", "csv", "addressbook"]

  def index
    @source = SOURCES.member?(params[:source]) ? params[:source] : raise(ActiveRecord::RecordNotFound)
  end

  protected
  def set_event
    @event = current_user.events.find(params[:event_id])
  end
end

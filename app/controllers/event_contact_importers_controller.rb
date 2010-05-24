class EventContactImportersController < ApplicationController
  before_filter :require_user, :set_event
  layout "event_contact_import"
  SOURCES = ["email", "csv", "addressbook"]

  def index
    @source = SOURCES.member?(params[:source]) ? params[:source] : raise(ActiveRecord::RecordNotFound)
  end

  protected
  def set_event
    @event = current_user.events.find(params[:event_id])
  end
end

class GuestImportersController < ApplicationController
  before_filter :require_user, :set_event
  before_filter :set_source, :only => :new

  SOURCES = ["email", "csv", "addressbook"]
  TITLES = {
    "email" => N_("sadfasf"),
    "csv" => N_("Import from CSV File"),
    "addressbook" => N_("Import from eventify's address book")
  }

  def create
    set_source if params[:source]

    if "csv" == params[:source]
      _load_csv_file
    else
      guests_imported = @event.guests.import(selected_contracts)
      flash[:notice] = n_("%d guest imported", "%d guests imported", guests_imported) % guests_imported
      redirect_to event_guests_path(@event)
    end
  end

  def new
  end

protected
  def set_source
    @source = SOURCES.member?(params[:source]) ? params[:source] : raise(ActiveRecord::RecordNotFound)
  end

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

  def _load_csv_file
    @contacts = []

    unless params[:csvfile].blank?
      contacts, error = ContactImporter.import_contacts(nil, nil, "csv", params[:csvfile])
      @contacts = ContactImporter.contacts_to_openstruct(contacts) if contacts
      @error = error.to_s if error
    end
  end
end

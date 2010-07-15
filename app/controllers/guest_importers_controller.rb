class GuestImportersController < ApplicationController
  before_filter :require_user, :set_event
  before_filter :set_source, :only => :new

  SOURCES = ["email", "csv", "addressbook"]
  TITLES = {
    "email" => N_("Import from mail"),
    "csv" => N_("Import CSV file"),
    "addressbook" => N_("Import from eventify's address book")
  }

  def create
    unless params[:source]
      guests_imported = @event.guests.import(selected_contracts)
      flash[:notice] = n_("%d guest imported", "%d guests imported", guests_imported) % guests_imported
      redirect_to event_guests_path(@event)
      return
    end

    _import

    responds_to_parent do
      render(:update) do |page|
        if @error
          render_new_guests_import_form(page)
        else
          page << "jQuery.nyroModalManual({content:#{render(:partial => "import", :locals => {:title => s_(GuestImportersController::TITLES[@source]), :contacts => @contacts}).to_json}})"
          page << "jQuery('body').css('cursor', 'default')"
        end
      end
    end
  end

  def new
    params[:contact_source] ||= "gmail"
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
      @contacts = ContactImporter.contacts_to_openstruct(contacts) if contacts && contacts.is_a?(Array)
      @error = error.to_s if error
    else
      @error = _("Please upload a CSV file")
    end
  end

  def _load_from_emails
    @contacts = []
    contacts, error = ContactImporter.import_contacts(params[:username], params[:password], params[:contact_source], nil)
    @contacts = ContactImporter.contacts_to_openstruct(contacts) if contacts && contacts.is_a?(Array)
    @error = error.to_s if error
  end

  def _import
    set_source

    if "csv" == params[:source]
      _load_csv_file
    elsif "email" == params[:source]
      _load_from_emails
    end
  end
end

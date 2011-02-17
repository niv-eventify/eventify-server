class GuestImportersController < ApplicationController
  before_filter :require_user, :event_by_user_or_host
  before_filter :set_source, :only => :new

  SOURCES = ["email", "csv", "addressbook", "email_list"]
  TITLES = {
    "email" => N_("Import from mail"),
    "csv" => N_("Import CSV file"),
    "addressbook" => N_("Import from eventify's address book"),
    "email_list" => N_("Import from existing email list")
  }

  def create
    return _import_guests  unless params[:source]
    _load_from_source
    @contacts.sort! {|a, b| a.name <=> b.name}
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

  def selected_contracts
    returning([]) do |res|
      params[:contact].keys.each do |k|
        res << params[:contact][k] if "1" == params[:contact][k][:import]
      end
    end
  end

  def _load_csv_file
    @contacts = []
    contacts = []
    unless params[:csvfile].blank?
      contacts, error = ContactImporter.import_contacts(nil, nil, "csv", params[:csvfile])
      @error = error.to_s if error
    end
    contacts1 = []
    unless params[:email_list].blank?
      contacts1, error = ContactImporter.import_contacts(params[:username], params[:password], params[:contact_source], params[:email_list])
      contacts.concat(contacts1.nil? ? [] : contacts1)
      @error1 = error.to_s if error
    end
    if params[:csvfile].blank? and params[:email_list].blank?
      @error = _("Please upload a CSV file")
    end
    @contacts = ContactImporter.contacts_to_openstruct(contacts.uniq) unless contacts.blank?
  end

  def _load_from_emails
    @contacts = []
    contacts, error = ContactImporter.import_contacts(params[:username], params[:password], params[:contact_source], nil)
    @contacts = ContactImporter.contacts_to_openstruct(contacts) if contacts && contacts.is_a?(Array)
    @error = error.to_s if error
  end

  def _load_from_source
    set_source

    if "csv" == params[:source]
      _load_csv_file
    elsif "email" == params[:source]
      _load_from_emails
    end
  end

  def _import_guests
    new_contacts = selected_contracts
    guests_imported = @event.guests.import(new_contacts, params[:save_to_addressbook])
    flash[:notice] = n_("%d guest imported", "%d guests imported", guests_imported) % guests_imported
    if params[:save_to_addressbook] && !guests_imported.blank?
      new_contacts.each do |g|
        current_user.contacts.add(g["name"], g["email"])
      end
    end
    redirect_to event_guests_path(@event)
  end
end

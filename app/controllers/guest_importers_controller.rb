class GuestImportersController < ApplicationController
  before_filter :require_user, :event_by_user_or_host, :except => [:gmail_callback, :import_failure]
  before_filter :set_source, :only => :new

  SOURCES = ["email", "csv", "addressbook", "email_list", "past_events"]
  TITLES = {
    :email => N_("Import from mail"),
    :csv => N_("Import CSV file"),
    :addressbook => N_("Import from eventify's address book"),
    :email_list => N_("Import from existing email list"),
    :past_events => N_("Import guests from past events")
  }.with_indifferent_access

  def create
    return _import_guests  unless params[:source]
    @check_all_by_default = false
    _load_from_source
    @contacts.sort! {|a, b| a.name <=> b.name}
    if params[:oauth2_data].blank?
      responds_to_parent do
        render(:update) do |page|
          if @error
            split_error = @error.split(" : ")
            if split_error[0] == "CaptchaRequired"
              #split_code = split_error[1].split("%3A")
              @image_url = "http://www.google.com/accounts/#{split_error[1]}"
              #@image_url = "http://www.google.com/accounts/#{split_code[0]}"
              @ctoken = CGI::unescape(split_error[1].split("?ctoken=")[1])
              @error = nil
            end
            render_new_guests_import_form(page)
          else
            page << "jQuery.nyroModalManual({content:#{render(:partial => "import", :locals => {:title => s_(GuestImportersController::TITLES[@source]), :contacts => @contacts}).to_json}})"
            page << "jQuery('body').css('cursor', 'default')"
          end
        end
      end
    else
      render(:update) do |page|
        if @error
          split_error = @error.split(" : ")
          if split_error[0] == "CaptchaRequired"
            #split_code = split_error[1].split("%3A")
            @image_url = "http://www.google.com/accounts/#{split_error[1]}"
            #@image_url = "http://www.google.com/accounts/#{split_code[0]}"
            @ctoken = CGI::unescape(split_error[1].split("?ctoken=")[1])
            @error = nil
          end
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

  def gmail_callback
    logger.info("omnicontacts.contacts: #{request.env['omnicontacts.contacts']}")
    @oauth2_response = CGI::escape(YAML::dump(request.env['omnicontacts.contacts']))
    logger.info("parsed omnicontacts.contacts: #@oauth2_response")
    render :file => "guest_importers/oauth2_callback", :layout => false
  end

  def import_failure
    @error_message = params[:error_message]
    render :file => "guest_importers/oauth2_failure", :layout => false
  end
protected
  def set_source
    @source = SOURCES.member?(params[:source]) ? params[:source] : raise(ActiveRecord::RecordNotFound)
    @past_events = current_user.events.find(:all, :conditions => "events.id IN (SELECT DISTINCT events.id FROM events, guests where guests.event_id = events.id)", :order => "created_at DESC")
  end

  def selected_contracts
    return [] if params[:contact].blank?
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
    unless params[:email_list].blank?
      contacts1, error = ContactImporter.import_contacts(params[:username], params[:password], params[:contact_source], params[:email_list])
      contacts.concat(contacts1.nil? ? [] : contacts1)
      @check_all_by_default = true if params[:csvfile].blank?
      @error1 = error.to_s if error
    end
    if params[:csvfile].blank? and params[:email_list].blank?
      @error = _("Please upload a CSV file")
    end
    @contacts = ContactImporter.contacts_to_openstruct(contacts.uniq) unless contacts.blank?
  end

  def _load_from_oauth2
    contacts = YAML::load(CGI::unescape(params[:oauth2_data]))
    @contacts = ContactImporter.contacts_to_openstruct(contacts.uniq) unless contacts.blank?
  end

  def _load_from_emails
    @contacts = []
    contacts, error = ContactImporter.import_contacts(params[:username], params[:password], params[:contact_source], nil,params[:ctoken], params[:captcha])
    @contacts = ContactImporter.contacts_to_openstruct(contacts) if contacts && contacts.is_a?(Array)
    @error = error.to_s if error
  end

  def _load_from_past_event
    contacts = Event.find_by_id(params[:target_event]).guests.map{|g| [g.name, g.email, g.mobile_phone]}
    @contacts = ContactImporter.contacts_to_openstruct(contacts.uniq) unless contacts.blank?
  end

  def _load_from_source
    set_source

    if "csv" == params[:source]
      _load_csv_file
    elsif "email" == params[:source]
      if params[:oauth2_data].blank?
        _load_from_emails
      else
        _load_from_oauth2
      end
    elsif "past_events" == params[:source]
      _load_from_past_event
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

class ContactImporter < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :contact_source

  SOURCES = returning(ActiveSupport::OrderedHash.new) do |h|
    # h["aol"] = "AOL"
    h["yahoo"] = "Yahoo!"
    h["gmail"] = "GMail"
    h["hotmail"] = "Hotmail"
    h["csv"] = "CSV file"
  end
  validates_inclusion_of :contact_source, :in => SOURCES.keys, :message => "not included in the list"
  attr_accessible :contact_source
  
  attr_accessor :username, :password, :csv, :validate_importing
  attr_accessible :username, :password, :csv, :validate_importing

  validates_presence_of :username, :password, :if => :validate_credentials?
  validates_presence_of :csv, :if => :validate_csv?

  def validate_credentials?; @validate_importing && !csv?; end
  def validate_csv?; @validate_importing && csv?; end

  def validate
    if @validate_importing && "yahoo" == contact_source && !(username =~ /@yahoo.com$/i)
      errors.add(:username, "is not a yahoo email")
    end
  end

  def to_param
    contact_source
  end

  def csv?
    "csv" == contact_source
  end

  def name
    SOURCES[contact_source]
  end

  def self.import_contacts(username, password, contact_source, csv)
    error = nil
    no_mails = nil

    contacts = case contact_source
    when 'gmail', 'hotmail', 'yahoo'
      begin
        connection = Contacts.new(contact_source.to_sym, username, password)
        connection.contacts
      rescue Contacts::StandardError, Contacts::ContactsError
        error = $!
        nil
      rescue
        error = _("A problem importing your contacts occured, please try again later.")
        nil
      end
    when 'aol'
      begin
        contacts = Blackbook.get(:username => username, :password => password)
      rescue Blackbook::BlackbookError, ArgumentError
        error = $!
        nil
      end
    when 'csv'
      begin
        res = Astrails::OutlookContact.get(csv)
        error = _("A problem importing your contacts occured, please try again later.") unless res
        res
      rescue
        error = _("A problem importing your contacts occured, please try again later.")
        nil
      end
    when 'email_list'
      begin
        res = Astrails::EmailList.get(csv)
        error = _("A problem importing your contacts occured, please try again later.") if res[:contacts].blank?
        no_mails = res[:no_mails] unless res[:no_mails].blank?
        res[:contacts]
      rescue
        error = _("A problem importing your contacts occured, please try again later.")
        nil
      end
    end

    [contacts.try(:uniq), error, no_mails]
  end

  def self.parse_name_and_email(c)
    if c.is_a?(Array)
      name, email = c.first, c.last
    elsif c.is_a?(Hash)
      name = c[:name] || c[:Name]
      email = c[:email] ||c [:Email]
    end
    [name || email, email]
  end

  def self.contacts_to_openstruct(contacts)
    id = 0

    contacts.map do |contact|
      returning(OpenStruct.new) do |res|
        name, email = parse_name_and_email(contact)
        res.name = name || email
        res.email = email
        res.mobile = nil
        res.uid = id
        id += 1
      end
    end
  end

  def import!(username = nil, password = nil)
    contacts, error = ContactImporter.import_contacts(username, password, contact_source, csv)

    _import!(contacts) if contacts
    _error!(error) if error
  end

protected
  def _import!(contacts)
    self.contacts_imported = 0
    contacts.each do |c|
      name, email = ContactImporter.parse_name_and_email(c)
      c = user.contacts.add(name, email)
      self.contacts_imported += 1 unless c.new_record?
    end
    self.completed_at = Time.now.utc
    save!
  end

  def _error!(exception)
    self.last_error = exception.to_s
    self.completed_at = Time.now.utc
    save!
    nil
  end
end

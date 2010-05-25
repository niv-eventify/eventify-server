class ContactImporter < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :contact_source

  SOURCES = returning(ActiveSupport::OrderedHash.new) do |h|
    h["aol"] = "AOL"
    h["gmail"] = "GMail"
    # h["yahoo"] = "Yahoo!"
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

    contacts = case contact_source
    when 'gmail', 'hotmail', 'yahoo'
      begin
        Contacts.new(contact_source.to_sym, username, password).contacts
      rescue Contacts::StandardError, Contacts::ContactsError
        error = $!
      rescue
        error = _("A problem importing your contacts occured, please try again later.")
      end
    when 'aol'
      begin
       contacts = Blackbook.get(:username => username, :password => password)
     rescue Blackbook::BlackbookError, ArgumentError
       error = $!
     end
    when 'csv'
      begin
        Blackbook.get(:csv, :file => csv)
      rescue Blackbook::BlackbookError
        error = $!
      end
    end
    
    [contacts, error]
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
      if c.is_a?(Array)
        name, email = c.first, c.last
      elsif c.is_a?(Hash)
        name = c[:name]
        email = c[:email]
      end
      self.contacts_imported += 1 if user.contacts.add(name, email)
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

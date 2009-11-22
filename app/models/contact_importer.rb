class ContactImporter < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :contact_source

  SOURCES = {
    "gmail" => "GMail",
    "yahoo" => "Yahoo!",
    "hotmail" => "Hotmail",
    "aol" => "AOL",
    "csv" => "CSV file"
  }
  validates_inclusion_of :contact_source, :in => SOURCES.keys, :message => "not included in the list"
  attr_accessible :contact_source
  
  attr_accessor :username, :password
  attr_accessible :username, :password
  attr_reader :validate_credentials
  validates_presence_of :username, :password, :if => :validate_credentials
  def validate_user_password(opts)
    self.attributes = opts
    @validate_credentials = true
    valid?
  end

  def to_param
    contact_source
  end

  def name
    SOURCES[contact_source]
  end

  def import!(opts)
    username = opts[:contact_importer][:username]
    password = opts[:contact_importer][:password]

    contacts = case contact_source
    when 'gmail', 'yahoo', 'hotmail'
      begin
        Contacts.new(contact_source.to_sym, username, password).contacts
      rescue Contacts::StandardError, Contacts::ContactsError
        _error!($!)
      end
    when 'aol'
      begin
       contacts = Blackbook.get :username => username, :password => password
     rescue Blackbook::BlackbookError
       _error!($!)
     end
    when 'csv'  
    end

    _import!(contacts) if contacts
  end

protected
  def _import!(contacts)
    self.contacts_imported = 0
    contacts.each do |name, email|
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

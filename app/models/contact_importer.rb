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
  
  attr_accessor :username, :password, :csv, :validate_importing
  attr_accessible :username, :password, :csv, :validate_importing

  validates_presence_of :username, :password, :if => :validate_credentials?
  validates_presence_of :csv, :if => :validate_csv?

  def validate_credentials?; @validate_importing && !csv?; end
  def validate_csv?; @validate_importing && csv?; end

  def to_param
    contact_source
  end

  def csv?
    "csv" == contact_source
  end

  def name
    SOURCES[contact_source]
  end

  def import!(opts)
    contacts = case contact_source
    when 'gmail', 'yahoo', 'hotmail'
      begin
        Contacts.new(contact_source.to_sym, username, password).contacts
      rescue Contacts::StandardError, Contacts::ContactsError
        _error!($!)
      end
    when 'aol'
      begin
       contacts = Blackbook.get(:username => username, :password => password)
     rescue Blackbook::BlackbookError
       _error!($!)
     end
    when 'csv'
      begin
        Blackbook.get(:csv, :file => csv)
      rescue Blackbook::BlackbookError
        _error!($!)
      end
    end

    _import!(contacts) if contacts
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

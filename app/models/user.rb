class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.merge_validates_format_of_email_field_options :live_validator => String::EMAIL_REGEX
    c.validates_length_of_password_field_options =
      {:on => :update, :minimum => 4, :if => :has_no_credentials?}
    c.validates_length_of_password_confirmation_field_options =
      {:on => :update, :minimum => 4, :if => :has_no_credentials?}
    c.perishable_token_valid_for = 2.weeks
  end
  include Astrails::Auth::Model
  attr_accessible :name, :password, :password_confirmation
  validates_presence_of :name


  has_many :contacts, :conditions => "contacts.removed_at IS NULL", :order => "contacts.email" do
    def add(name, email)
      return false if find_by_email(email)
      return false if email.blank?
      unless name
        email =~ /(.+)@/
        name = $1
      end
      !create(:name => name, :email => email).new_record?
    end
  end
  has_many :contact_importers do
    def reset_source!(new_source)
      importer = find_by_contact_source(new_source) || build(:contact_source => new_source)
      importer.completed_at = importer.last_error = importer.contacts_imported = nil
      importer.save!

      importer
    end
  end
end

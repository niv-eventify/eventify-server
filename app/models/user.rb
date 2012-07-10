class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.merge_validates_format_of_email_field_options :live_validator => String::EMAIL_REGEX
    c.validates_length_of_password_field_options =
      {:on => :update, :minimum => 4, :if => :has_no_credentials_and_password_changed?}
    c.validates_length_of_password_confirmation_field_options =
      {:on => :update, :minimum => 4, :if => :has_no_credentials_and_password_changed?}
    c.perishable_token_valid_for = 2.weeks
  end
  include Astrails::Auth::Model
  attr_accessible :name, :password, :password_confirmation, :old_password, :is_agreed_to_terms
  attr_accessor :old_password
  validates_presence_of :name, :if => :strip_name
  validate :old_passwords, :on => :update

  named_scope :enabled, {:conditions => "users.disabled_at IS NULL"}
  named_scope :disabled, {:conditions => "users.disabled_at IS NOT NULL"}
  named_scope :by_created_at, :order => "users.created_at DESC"

  def has_no_credentials_and_password_changed?
    has_no_credentials? || !password.blank? || !old_password.blank?
  end

  def disabled?
    !disabled_at.blank?
  end

  has_many :contacts, :conditions => "contacts.removed_at IS NULL", :order => "contacts.email" do
    def add(name, email)
      unless name
        email =~ /(.+)@/
        name = $1
      end
      create(:name => name, :email => email)
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

  has_many :events
  has_many :payments

  def strip_name
    self.name.strip!
    return true
  end

  # allow not activated users to access just created events
  def active?
    true
  end

  after_update :activate_events
  def activate_events
    if activated_at_changed? && !activated_at.nil?
      events.update_all "user_is_activated = 1"
    end
  end

  def old_passwords
    return unless password_changed?
    return if crypted_password_was.blank?
    if current_controller && current_controller.logged_in?
      errors.add(:old_password, _("is wrong")) unless valid_password?(old_password)
    end
  end
end

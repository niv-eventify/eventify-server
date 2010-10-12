class GuestsMessage < ActiveRecord::Base

  belongs_to :event

  validates_presence_of :subject , :body

  attr_accessible :subject , :body
  
  after_create :send_email_to_guests

  def send_email_to_guests
    event.guests.invite_by_email.each do |guest|
      Notifier.send_later :deliver_message_to_guest, guest, self
    end
  end
  handle_asynchronously :send_email_to_guests

end


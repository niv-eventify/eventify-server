class Contact < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of   :email, :with => String::EMAIL_REGEX, :message => "does't look like an email"

  attr_accessible :name, :email, :mobile, :country, :city, :street, :zip, :company, :title

end

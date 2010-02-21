Factory.define :guest do |guest|
  guest.sequence(:name) {|n| "Name#{n}"}

  guest.email {|a| "#{a.name}@example.com".downcase }
  guest.email_token "token"

  guest.association :event, :factory => :event
end

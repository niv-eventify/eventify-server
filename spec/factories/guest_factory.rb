Factory.define :guest do |guest|
  guest.sequence(:name) {|n| "Name#{n}"}

  guest.email {|a| "#{a.name}@example.com".downcase }

  guest.association :event, :factory => :event
end

Factory.define :guest_with_token, :parent => :guest do |guest|
  guest.email_token "token"
end

Factory.define :guest_with_mobile, :parent => :guest do |guest|
  guest.mobile_phone "0500000000"
end


Factory.define :guest_with_sms, :parent => :guest_with_mobile do |guest|
  guest.send_sms true
  guest.sms_invitation_sent_at 10.minutes.ago.utc
  guest.sms_invitation_failed_at 9.minutes.ago.utc
end
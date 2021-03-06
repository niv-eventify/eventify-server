Factory.define :guest_without_email_and_phone, :class => Guest do |guest|
  guest.sequence(:name) {|n| "Name#{n}"}
  guest.association :event, :factory => :event
  guest.summary_email_sent_at 10.minutes.ago
end

Factory.define :guest do |guest|
  guest.sequence(:name) {|n| "Name#{n}"}

  guest.email {|a| "#{a.name}@example.com".downcase }

  guest.association :event, :factory => :event
  guest.summary_email_sent_at 10.minutes.ago
  guest.send_email 1
end

Factory.define :guest_from_event_with_mobile, :parent => :guest do |guest|
  guest.association :event, :factory => :event_with_mobile
end

Factory.define :guest_with_token, :parent => :guest do |guest|
  guest.email_token "token"
end

Factory.define :guest_with_bounce, :parent => :guest_with_token do |guest|
  guest.email_token "token"
  guest.bounced_at Time.now.utc
end


Factory.define :guest_with_mobile, :parent => :guest_from_event_with_mobile do |guest|
  guest.mobile_phone "050-1234567"
  guest.send_sms  1
end


Factory.define :guest_with_sms, :parent => :guest_with_mobile do |guest|
  guest.send_sms true
  guest.sms_invitation_sent_at 10.minutes.ago.utc
  guest.sms_invitation_failed_at 9.minutes.ago.utc
end

Factory.define :guest_summary_not_sent, :parent => :guest do |guest|
  guest.name "New Guest"
  guest.email "new@guest.com"
  guest.attendees_count 3
  guest.summary_email_sent_at nil
  guest.rsvp  1
end

Factory.define :guest_with_sent_inviations, :parent => :guest_summary_not_sent do |guest|
  guest.email_invitation_sent_at Time.now.utc
  guest.sms_invitation_sent_at Time.now.utc
end
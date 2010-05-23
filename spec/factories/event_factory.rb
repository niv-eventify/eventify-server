Factory.define :event do |event|
  event.sequence(:name) {|n| "Name#{n}"}
  event.category_id 12
  event.design_id 13
  event.location_name "foobar"
  event.association :user, :factory => :active_user
  event.starting_at 10.days.from_now
  event.language "en"
  event.user_is_activated true
end

Factory.define :inactive_event, :parent => :event do |event|
  event.association :user, :factory => :user
  event.user_is_activated false
end

Factory.define :event_with_mobile , :parent => :event do |event|
  event.host_mobile_number "0544444444"
  event.sms_message "hey you"
end

Factory.define :event_with_daily_summary, :parent => :event do |event|
  event.rsvp_summary_send_every 2
  event.starting_at 10.days.from_now
  event.rsvp_summary_send_at 1.day.ago
end

Factory.define :event_with_daily_summary_never_sent, :parent => :event do |event|
  event.rsvp_summary_send_every 2
end
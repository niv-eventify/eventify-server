Factory.define :event do |event|
  event.sequence(:name) {|n| "Name#{n}"}
  event.category_id 12
  event.design_id 13
  event.location_name "foobar"
  event.association :user, :factory => :active_user
  event.starting_at 10.days.from_now
  event.language "en"
end

Factory.define :event_with_daily_summary, :parent => :event do |event|
  event.rsvp_summary_send_every 2
  event.starting_at 10.days.from_now
  event.rsvp_summary_send_at 1.day.ago
end

Factory.define :event_with_daily_summary_never_sent, :parent => :event do |event|
  event.rsvp_summary_send_every 2
end
Factory.define :event do |event|
  event.sequence(:name) {|n| "Name#{n}"}
  event.category_id 12
  event.design_id 13
  event.location_name "foobar"
  event.association :user, :factory => :user
  event.starting_at 10.days.from_now
end

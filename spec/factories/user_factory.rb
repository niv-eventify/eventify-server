Factory.define :user do |user|
  user.sequence(:name) {|n| "Name#{n}"}

  user.email {|a| "#{a.name}@example.com".downcase }

  user.password              'qweqwe'
  user.password_confirmation 'qweqwe'

  user.skip_session_maintenance true
end

Factory.define :active_user, :parent => :user do |user|
  user.sequence(:email) {|a| "#{a}@example1.com".downcase }
  user.activated_at 1.month.ago.utc
end

Factory.define :admin, :parent => :active_user do |user|
  user.sequence(:email) {|a| "#{a}@example2.com".downcase }
  user.is_admin true
end


Factory.define :disabled_user, :parent => :active_user do |user|
  user.disabled_at 1.day.ago.utc
end

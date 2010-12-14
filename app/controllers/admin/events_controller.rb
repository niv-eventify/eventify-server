class Admin::EventsController < InheritedResources::Base

  before_filter :require_admin
  has_scope :by_created_at, :default => true
  has_scope :by_user_id

  actions :index

end

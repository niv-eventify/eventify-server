class Admin::EventsController < InheritedResources::Base

  before_filter :require_admin
  has_scope :by_created_at, :default => true

  actions :index

end

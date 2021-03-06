class Admin::PaymentsController < InheritedResources::Base

  before_filter :require_admin
  has_scope :for_list, :default => true
  has_scope :paid, :default => true

  actions :index

end

class Admin::NetpayLogsController < InheritedResources::Base

  before_filter :require_admin
  has_scope :for_list, :default => true

  actions :index

end

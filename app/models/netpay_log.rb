class NetpayLog < ActiveRecord::Base
  attr_accessible :all

  named_scope :for_list, :order => "created_at DESC"
end

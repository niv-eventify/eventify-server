class Array
  def compact_blanks
    self.select {|v| !v.blank?}
  end
end


module Delayed
  class Job < ActiveRecord::Base
    attr_accessible :priority, :payload_object, :run_at
  end
end


class ActiveRecord::Base
  def changed_to_nil?(attr_name)
    send("#{attr_name}_changed?") && send(attr_name).nil?
  end
end
class Array
  def compact_blanks
    self.select {|v| !v.blank?}
  end
end

Delayed::Backend::ActiveRecord::Job.attr_accessible :priority, :payload_object, :run_at, :locked_at, :failed_at, :locked_by


class ActiveRecord::Base
  def changed_to_nil?(attr_name)
    send("#{attr_name}_changed?") && send(attr_name).nil?
  end
end

class String
  def to_quoted_printable
    [self].pack("M").gsub(/\n/, "\r\n")
  end
end

class Fixnum
  def format_cents(decimals = true)
    return sprintf("%.2f", self.to_f/100) if decimals

    if (self % 100).zero?
      (self / 100).to_i
    else
      format_cents(true)
    end
  end
end
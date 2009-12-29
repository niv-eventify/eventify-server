module TrustedDateTimeSelect
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def datetime_select_accessible(*attribute)
      attribute.each do |a|
        0.step(6) do |i|
          attr_accessible "#{a}(#{i}i)"
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, TrustedDateTimeSelect)



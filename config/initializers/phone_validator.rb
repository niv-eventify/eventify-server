module ActiveRecord
  module Validations
    module ClassMethods      
      def validates_phone_number(*attr_names)
        validates_each(*attr_names) do |record, attr_name, value|
          next if value.blank?
          record.errors.add(attr_name, _("does't look like a mobile phone number")) if beautify_number(value) !~ String::PHONE_REGEX
        end

      end
      def beautify_number(value)
        value.to_s.gsub(/-/, "")
      end
    end
  end
end
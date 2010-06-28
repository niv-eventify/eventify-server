module ActiveRecord
  module Validations
    module ClassMethods      
      def validates_sms_length_of(*attr_names)
        validates_each(*attr_names) do |record, attr_name, value|
          next if value.blank?

          if value.mb_chars.length > SmsMessage::MAX_LENGTH
            record.errors.add(:sms_message, _("is too long, %{chars} max") % {:chars => SmsMessage::MAX_LENGTH})
          end
        end
      end
    end
  end
end
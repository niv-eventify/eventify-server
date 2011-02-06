require 'logger'
module Astrails
  class EmailList
    class << self
      def get(email_list)
        return nil if email_list.blank?
        email_list = email_list.gsub(/</, "").gsub(/>/,"").gsub(/\r/, "").gsub(/\n/, "").gsub(/\t/, "")
        data_arr = email_list.split(/[,|;]/)
        res = []
        0.step(data_arr.length - 1) do |index|
          contact = data_arr[index].split(/ /)
          name = email = ""
          0.step(contact.length - 1) do |jindex|
            if String::EMAIL_INSIDE_REGEX.match(contact[jindex]) == nil
              name += contact[jindex] + " "
            else
              email = $&
            end
          end
          if email.blank? and not name.blank?
            res << [name, nil]
            next
          end
          name = name.strip
          name = email if name.blank?
          res << [name, email]
        end
        res          
      end
    end
  end
end
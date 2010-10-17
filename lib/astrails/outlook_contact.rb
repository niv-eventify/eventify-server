require 'logger'
module Astrails
  class OutlookContact
    EMAIL_COLUMNS = ["Email", "email", "E-mail Address", "E-mail Address 2", "E-mail Address 3", "כתובת דואר אלקטרוני", "2 כתובת דואר אלקטרוני", "3 כתובת דואר אלקטרוני", "דוא״ל ראשי", "דוא״ל משני"]
    class << self
      def get(csv)
        importer = Astrails::Importer.new(csv)
        return false if importer.data.blank?

        n_id = name_column_id(importer.data)
        e_id = email_column_id(importer.data)

        if n_id.blank? || e_id.blank?
          return importer.data.map do |id|
            [id[0], id[1]]
          end
        end

        if n_id.is_a?(Array)
          name = lambda {|d| "#{d[n_id.first]} #{d[n_id.last]}"}
        else
          name = lambda {|d| d[n_id]}
        end
        email = lambda {|d| d[e_id]}
        
        res = []
        returning([]) do |res|
          1.step(importer.data.size - 1) do |index|
            res << [name.call(importer.data[index]).to_s, email.call(importer.data[index]).to_s]
          end          
        end
      end

      def name_column_id(data)
        if name_id = data[0].index("Name")
          return name_id
        end

        if name_id = data[0].index("name")
          return name_id
        end

        if name_id = data[0].index("שם")
          return name_id
        end

        if (fname_id = data[0].index("First Name")) && (lname_id = data[0].index("Last Name"))
          return [fname_id, lname_id]
        end

        if (fname_id = data[0].index("שם פרטי")) && (lname_id = data[0].index("שם משפחה"))
          return [fname_id, lname_id]
        end

        nil
      end

      def email_column_id(data)
        EMAIL_COLUMNS.each do |c|
          if email_id = data[0].index(c)
            return email_id
          end
        end

        nil
      end
    end
  end
end
class Blackbook::Importer::Csv < Blackbook::Importer::Base
  def to_columns(line) # :nodoc:
    columns = Array.new
    tags = line.split(',')
    # deal with "Name,E-mail..." oddity up front
    if tags.first =~ /^name$/i
      tags.shift
      columns << :name
      if tags.first =~ /^e.?mail/i # E-mail or Email
        tags.shift
        columns << :email
      end
    end
    tags.collect(&:strip).compact_blanks.each{|v| columns << (v.to_sym rescue nil)}
    columns
  end  
end
require 'csv'
require "rchardet"
require "iconv"
require 'roo'

module Astrails
  class Importer
    
    UTF8 = "utf-8"

    def initialize(uploaded_data)
      @uploaded_data = uploaded_data
    end

    def data
      @data ||= convert rescue nil
    end

  protected
  
    def convert
      return nil unless @uploaded_data

      if csv = csv_detect
        csv_convert(csv)
      elsif xlsx = xlsx_detect
        xlsx_convert(xlsx)
      elsif xls = xls_detect
        xls_convert(xls)
      else
        nil
      end
    end

    def write_tmp_file(postfix = "")
      temp_file = Tempfile.new(Time.now.utc.to_i.to_s + postfix)
      temp_file.binmode
      @uploaded_data.rewind
      temp_file.write(@uploaded_data.read)
      temp_file.close
      temp_file
    end

    def xlsx_detect
      if @uploaded_data.respond_to?(:content_type)
        return false unless @uploaded_data.original_filename =~ /\.xlsx/
      end
      write_tmp_file(".xlsx")
    end

    def xls_detect
      if @uploaded_data.respond_to?(:content_type)
        return false unless @uploaded_data.original_filename =~ /xls/ || @uploaded_data.content_type =~ /excel/
      end
      write_tmp_file
    end

    def csv_detect
      if @uploaded_data.respond_to?(:content_type)
        return false unless @uploaded_data.original_filename =~ /csv/i || @uploaded_data.content_type =~ /text/
      else
        # assume CSV
      end
      case @uploaded_data
      when String
        @uploaded_data
      when StringIO
        @uploaded_data.rewind
        @uploaded_data.string
      when Tempfile, File
        @uploaded_data.read
      else
        nil
      end
    end

    def xlsx_convert(xlsx)
      xlsx.close
      x = Excelx.new(xlsx.path)
      x.default_sheet = x.sheets.first

      cols = []
      1.upto(x.last_row) do |r|
        vals = []
        1.upto(x.last_column) do |c|
          vals << x.cell(r, c).to_s
        end
        cols << vals
      end
      xlsx.unlink

      cols
    end

    def xls_convert(xls)
      xls.close
      workbook = Spreadsheet::ParseExcel.parse(xls.path)
      worksheet = workbook.worksheet(0)

      cols = []
      worksheet.each do |row|
        vals = []
        row.each do |cell|
          if cell.is_a?(Spreadsheet::ParseExcel::Worksheet::Cell)
            vals << cell.to_s(UTF8)
          else
            vals << cell.to_s
          end
        end
        cols << vals
      end
      xls.unlink
      cols
    end

    def csv_convert(csv)
      source_encoding = CharDet.detect(csv)["encoding"]
      csv = Iconv.iconv(UTF8, source_encoding, csv).first if source_encoding != UTF8 && source_encoding
      cols = []
      FasterCSV.parse(csv) { |row| cols << row }
      cols
    end
  end
end
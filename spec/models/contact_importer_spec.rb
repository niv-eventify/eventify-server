require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactImporter do
  before(:each) do
    @contact_importer = ContactImporter.new
  end

  describe "validations" do
    before(:each) do
      @contact_importer.should_not be_valid
    end

    it "should validate source" do
      @contact_importer.errors.on(:contact_source).should_not be_blank
    end
  end

  describe "import" do
    describe "validation" do
      it "should validate user/password for not csv types" do
        (ContactImporter::SOURCES.keys - ["csv"]).each do |s|
          @contact_importer.contact_source = s
          @contact_importer.validate_importing = true
          @contact_importer.should_not be_valid
          [:password, :username].each do |k|
            @contact_importer.errors.on(k).should_not be_blank
          end
        end
      end
      it "should validate file on csv" do
        @contact_importer.contact_source = "csv"
        @contact_importer.validate_importing = true
        @contact_importer.should_not be_valid
        @contact_importer.errors.on(:csv).should_not be_blank
      end
    end

    # describe "importer"
  end
end

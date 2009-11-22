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
end

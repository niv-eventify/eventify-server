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

    describe "importer" do
      before(:each) do
        @contact_importer.username = "username"
        @contact_importer.password = "password"
        @contact_importer.csv = "file"
        @contacts = [["full name", "email@email.com"], ["full name2", "email2@email.com"]]
        @contacts.stub!(:contacts).and_return(@contacts)
      end
      ['gmail', 'yahoo', 'hotmail'].each do |s|
        it "should use Contacts importer" do
          @contact_importer.contact_source = s
          Contacts.stub!(:new).with(s.to_sym, "username", "password").and_return(@contacts)
          Contacts.should_receive(:new).with(s.to_sym, "username", "password").and_return(@contacts)
          @contact_importer.should_receive(:_import!).with(@contacts)
          @contact_importer.import!
        end
      end
      it "should use Blackbook for aol" do
        @contact_importer.contact_source = "aol"
        Blackbook.stub!(:get).with(:username => "username", :password => "password").and_return(@contacts)
        Blackbook.should_receive(:get).with(:username => "username", :password => "password").and_return(@contacts)
        @contact_importer.should_receive(:_import!).with(@contacts)
        @contact_importer.import!
      end
      it "should use Blackbook for csv" do
        @contact_importer.contact_source = "csv"
        Blackbook.stub!(:get).with(:csv, :file => "file").and_return(@contacts)
        Blackbook.should_receive(:get).with(:csv, :file => "file").and_return(@contacts)
        @contact_importer.should_receive(:_import!).with(@contacts)
        @contact_importer.import!
      end

      it "should do actual import" do
        @contact_importer.contact_source = "gmail"
        @contact_importer.user = Factory.create(:active_user)
        @contact_importer.send(:_import!, @contacts)
        new_contacts = Contact.all
        new_contacts.collect(&:name).should == ["full name", "full name2"]
        new_contacts.collect(&:email).should == ["email@email.com", "email2@email.com"]
        @contact_importer.reload.contacts_imported.should == 2
        @contact_importer.last_error.should be_blank
      end

      it "should save error" do
        @contact_importer.contact_source = "gmail"
        @contact_importer.send(:_error!, "error description")
        @contact_importer.last_error.should == "error description"
      end
    end
  end
end

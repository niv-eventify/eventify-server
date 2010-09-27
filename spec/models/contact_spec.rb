require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contact do
  before(:each) do
    @valid_attributes = {
      :email => "aaa@bbb.com",
      :name => "foobar"
    }
  end

  it "should create a new instance given valid attributes" do
    @contact = Contact.new(@valid_attributes)
    @contact.user_id = 12
    @contact.save!
  end

  describe "validations" do
    before(:each) do
      @contact = Contact.new
      @contact.should_not be_valid
    end

    [:user_id, :email, :name].each do |a|
      it "should validate #{a}" do
        @contact.errors.on(a).should_not be_blank
      end
    end

    describe "uniquness" do
      it "should validate uniquness" do
        c = Contact.new(:name => "foo", :email => "foo@car.com")
        c.user_id = 12
        c.save.should be_true
        c = Contact.new(:name => "foo", :email => "foo@car.com")
        c.user_id = 12
        c.should_not be_valid
        c.errors.on(:email).should_not be_blank
      end

      it "should allow deleting" do
        c = Contact.new(:name => "foo", :email => "foo@car.com")
        c.user_id = 12
        c.save!

        c.removed_at = Time.now.utc
        c.save!

        # allows to create new one with same email
        c = Contact.new(:name => "foo", :email => "foo@car.com")
        c.user_id = 12
        c.save.should be_true

        # and delete again
        c.removed_at = Time.now.utc
        c.save.should be_true

        # and create again with same email
        c = Contact.new(:name => "foo", :email => "foo@car.com")
        c.user_id = 12
        c.save.should be_true

        Contact.find(:all, :conditions => ["email = ?", "foo@car.com"]).size.should == 3
      end
    end
  end
end

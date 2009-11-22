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
  end
end

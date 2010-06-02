require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SmsMessage do
  before(:each) do
    @guest = Factory.create(:guest_with_mobile)
    @valid_attributes = {
      :guest => @guest,
      :message => "sdfasfasf"
    }
  end

  it "should create a new instance given valid attributes" do
    sms = SmsMessage.create!(@valid_attributes)
    sms.receiver_mobile.should == "0501234567"
  end

  [:guest_id, :event_id, :receiver_mobile, :message, :sender_mobile].each do |a|
    it "should validate #{a}" do
      message = SmsMessage.new
      message.should_not be_valid
      message.errors.on(a).should_not be_blank
    end
  end
end

require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  describe "sms sending validations" do
    before(:each) do
      @event = Factory.create(:event)
    end

    describe "not sending sms" do      
      before(:each) do
        @event.stub!(:should_send_sms?).and_return(false)
        @event.send_invitations_now = true
      end

      it "should be valid" do
        @event.should be_valid
      end
    end

    describe "sending sms" do      
      before(:each) do
        @event.stub!(:should_send_sms?).and_return(true)
        @event.send_invitations_now = true
      end

      describe "validations" do
        before(:each) do
          @event.should_not be_valid
        end

        it "validate sms_message" do
          @event.errors.on(:sms_message).should_not be_blank
        end

        it "validate host mobile" do
          @event.errors.on(:host_mobile_number).should_not be_blank
        end
      end
    end
  end
end

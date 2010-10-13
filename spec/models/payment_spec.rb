require 'spec_helper'

describe Payment do
  
  before(:each) do
    @payment = Payment.new
  end

  it "should have upgrade plan for new" do
    plan, price = Payment.upgrade_plan(:emails_plan, 101, 0)
    plan.should == 200
    price.should == 0
  end

  it "should have upgrade plan for paid" do
    plan, price = Payment.upgrade_plan(:emails_plan, 201, 101)
    plan.should == 300
    price.should == 0
  end

  it "should calculate amount" do
    event = mock("event")
    event.stub!(:sms_plan).and_return(1)
    event.stub!(:emails_plan).and_return(2)
    event.stub!(:prints_plan).and_return(3)

    @payment.sms_plan = 1
    @payment.emails_plan = 2
    @payment.prints_plan = 3
    
    Payment.should_receive(:upgrade_plan).with(:sms_plan, 1, 1).and_return([0, 1])
    Payment.should_receive(:upgrade_plan).with(:emails_plan, 2, 2).and_return([0, 10])
    Payment.should_receive(:upgrade_plan).with(:prints_plan, 3, 3).and_return([0, 100])

    @payment.stub!(:event).and_return(event)

    @payment.calculated_amount.should == 111
  end

  describe "pay" do
    it "should raise when not valid" do
      @payment.stub!(:valid?).and_return(false)
      lambda {@payment.pay!}.should raise_error(ActiveRecord::RecordInvalid)
    end

    describe "netpay" do
      before(:each) do
        @payment.event = Factory.create(:event)
        @netpay = mock("netpay")
        Netpay::SilentPost.stub!(:new).and_return(@netpay)
        @netpay.stub!(:process)
        @netpay.stub!(:parsed_response).and_return({:ReplyDesc => "ReplyDesc"})
      end

      it "should raise when payment failed" do
        @netpay.stub!(:success?).and_return(false)
        @payment.stub!(:valid?).and_return(true)
        lambda {@payment.pay!}.should raise_error(PaymentError)
      end

      it "should save log id and paid_at when succeed" do
        @netpay.stub!(:success?).and_return(true)
        @netpay.stub!(:log_id).and_return(123)
        @payment.stub!(:valid?).and_return(true)
        @payment.pay!.should be_true
        @payment.paid_at.should_not be_blank
        @payment.succeed_netpay_log_id.should == 123
      end
    end
  end
end

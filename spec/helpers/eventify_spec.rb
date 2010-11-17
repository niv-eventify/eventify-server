require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Eventify do
  it "should calculate emails amounts" do
    Eventify.emails_plan(1).should == [20, 0]
    Eventify.emails_plan(20).should == [20, 0]
    Eventify.emails_plan(21).should == [100, 0]
    Eventify.emails_plan(100).should == [100, 0]
    Eventify.emails_plan(101).should == [200, 0]
    Eventify.emails_plan(200).should == [200, 0]
    Eventify.emails_plan(201).should == [300, 0]
    Eventify.emails_plan(300).should == [300, 0]
    Eventify.emails_plan(301).should == [500, 0]
    Eventify.emails_plan(500).should == [500, 0]
    Eventify.emails_plan(501, 200).should == [501, 100200]
  end

  it "should calculate sms amounts" do
    Eventify.sms_plan(1).should == [20, 0]
    Eventify.sms_plan(20).should == [20, 0]
    Eventify.sms_plan(21).should == [40, 0]
  end

  it "should calculate prints amounts" do
    Eventify.prints_plan(1).should == [50, 50*375]
    Eventify.prints_plan(50).should == [50, 50*375]
    Eventify.prints_plan(51).should == [100, 100*375]
  end
end
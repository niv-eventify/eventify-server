require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Taking do

  describe "things amounts" do
    before(:each) do
      @guest = Factory.create(:guest_with_token)
      @thing = @guest.event.things.create(:name => "foo", :amount => 5)
    end

    it "thing should have zero amount_picked" do
      @thing.amount_picked.should == 0
    end

    describe "overtake" do
      before(:each) do
        @taking = @guest.takings.create(:amount => 2, :thing_id => @thing.id)
        @another_guest = Factory.create(:guest_without_email_and_phone)
      end

      it "should auto reduce the takings amount" do
        @new_taking = @another_guest.takings.create(:amount => 5, :thing_id => @thing.id)
        @new_taking.amount.should == 3
      end
    end

    describe "rsvp changes" do
      before(:each) do
        @taking = @guest.takings.create(:amount => 2, :thing_id => @thing.id)
        @thing.reload.amount_picked.should == 2
      end

      [0, 2].each do |rsvp|
        it "should return things to stock when rsvp is #{rsvp}" do
          @guest.rsvp = rsvp
          @guest.save
          @thing.reload.amount_picked.should == 0
          @guest.takings.count.should be_zero
        end
      end

      it "should not change things if rsvp is YES" do
        @guest.rsvp = 1
        @guest.save
        @thing.reload.amount_picked.should == 2
        @guest.takings.count.should == 1    
      end
    end

    describe "changes" do
      before(:each) do
        @taking = @guest.takings.create(:amount => 2, :thing_id => @thing.id)
      end

      it "shoud decrement amount_picked when new taking is created" do
        @thing.reload.amount_picked.should == 2
        @thing.left_to_bring.should == 3
      end

      it "should increment amount_picked when some taking is returned" do
        @taking.amount = 3
        @taking.save
        @thing.reload.amount_picked.should == 3
        @thing.left_to_bring.should == 2
      end

      it "should decrement amount_picked when some taking amount is decresed" do
        @taking.amount = 1
        @taking.save
        @thing.reload.amount_picked.should == 1
        @thing.left_to_bring.should == 4
      end

      it "should reset amount_picked when taking deleted" do
        @taking.destroy
        @thing.reload.amount_picked.should == 0
        @thing.left_to_bring.should == 5
      end

      it "should send email to guest when taking is removed" do
        Notifier.should_receive(:deliver_taking_removed).with(@guest, @thing)
        @taking.destroy
      end

      it "should send email to guest when whole thing is removed" do
        Notifier.should_receive(:deliver_taking_removed).with(@guest, @thing)
        @thing.destroy
      end

      it "should not send email to guest if rsvp changed to no" do
        @guest.rsvp = 1
        @guest.save
        @guest.rsvp = 0

        Notifier.should_not_receive(:send_later).with(:deliver_taking_removed, @guest, @thing)
        @guest.save
      end
    end
  end
end

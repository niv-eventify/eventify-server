require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Taking do

  describe "things amounts" do
    before(:each) do
      @guest = Factory.create(:guest)
      @thing = @guest.event.things.create(:name => "foo", :amount => 5)
    end

    it "thing should have zero amount_picked" do
      @thing.amount_picked.should == 0
    end

    describe "changes" do
      before(:each) do
        @taking = @guest.takings.build(:amount => 2, :thing_id => @thing.id)
        @taking.event_id = @guest.event_id
        @taking.save
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
    end
  end
end

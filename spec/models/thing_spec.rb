require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Thing do
  context "general functionality" do
    before(:each) do
      @thing = Thing.new
      @thing.event_id = 123
    end
    describe "validations" do
      [:name, :amount].each do |a|
        it "validates #{a}" do
          @thing.should_not be_valid
          @thing.errors.on(a).should_not be_blank
        end
      end
    end

    it "amount validations" do
      @thing.name = "some name"

      @thing.amount = "asas"
      @thing.should_not be_valid
      @thing.errors.on(:amount).should_not be_blank

      @thing.amount = -10
      @thing.should_not be_valid
      @thing.errors.on(:amount).should_not be_blank

      @thing.amount = 12
      @thing.should be_valid
    end

    it "should not allow reducing amounts" do
      @thing.amount_picked = 12
      @thing.amount = 8
      @thing.should_not be_valid
      @thing.amount.should == 12
    end

    it "amount taken validations" do
      @thing.name = "some name"
    
      @thing.amount = -1
      @thing.amount_picked = 10
      @thing.should_not be_valid
      @thing.errors.on(:base).should_not be_blank
    end
  end

  context "takings" do
    before(:each) do
      @guest = Factory.create(:guest_with_token)
      @thing = @guest.event.things.create(:name => "foo", :amount => 5)
    end

    it "should be pickable" do
      takings = @guest.possible_takings
      takings.size.should == 1
      takings.first.should be_new_record
      takings.first.thing_id.should == @thing.id
      takings.first.amount.should be_zero
    end

    it "should generate taking" do
      @thing.to_taking.should be_new_record
    end

    it "should create new taking" do
      attrs = {:thing_id => @thing.id, :amount => 1}
      @guest.takings_attributes=({0 => attrs})
      taking = Taking.first
      taking.should_not be_nil
      taking.thing_id.should == @thing.id
      taking.amount.should == 1
      taking.event_id.should == @guest.event_id
    end

    it "should update existing taking" do
      attrs = {:thing_id => @thing.id, :amount => 1, :id => 123}
      @guest.should_receive(:change_existing_taking).with(attrs)
      @guest.takings_attributes=({0 => attrs})
    end

    describe "update taking" do
      before(:each) do
        @taking = @guest.takings.create(:thing_id => @thing.id, :amount => 2)
      end

      it "should change amount of existing" do
        attrs = {:thing_id => @thing.id, :amount => 1, :id => @taking.id}
        @guest.takings_attributes=({0 => attrs})
        @taking.reload.amount.should == 1
      end

      it "should remove taking" do
        attrs = {:thing_id => @thing.id, :amount => 0, :id => @taking.id}
        @guest.takings_attributes=({0 => attrs})
        Taking.find_by_id(@taking.id).should be_nil
      end
    end

  end
end

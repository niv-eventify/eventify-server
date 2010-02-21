require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Thing do
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

  it "amount taken validations" do
    @thing.name = "some name"
    
    @thing.amount = -1
    @thing.amount_picked = 10
    @thing.should_not be_valid
    @thing.errors.on(:base).should_not be_blank
  end
end

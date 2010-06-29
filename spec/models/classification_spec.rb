require 'spec_helper'

describe Classification do
  it "should create a new instance given valid attributes" do
    Classification.create!(:category_id => 1, :design_id => 2)
  end

  describe "validations" do
    before(:each) do
      @classification = Classification.new
      @classification.should_not be_valid
    end

    it "should validate category_id" do
      @classification.errors.on(:category_id).should_not be_blank
    end
  end
end

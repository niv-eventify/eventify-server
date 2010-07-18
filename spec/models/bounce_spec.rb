require 'spec_helper'

describe Bounce do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Bounce.create!(@valid_attributes)
  end
end

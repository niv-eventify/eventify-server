require 'spec_helper'

describe Host do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Host.create!(@valid_attributes)
  end
end

require 'spec_helper'

describe Garden do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Garden.create!(@valid_attributes)
  end
end

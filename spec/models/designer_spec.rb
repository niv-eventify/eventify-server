require 'spec_helper'

describe Designer do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Designer.create!(@valid_attributes)
  end
end

require File.dirname(__FILE__) + '/../spec_helper'

describe Category do
  before(:each) do
    @category = Category.new
    @category.should_not be_valid
  end

  [:name_en, :name_he].each do |a|
    it "should validate #{a}" do
      @category.errors.on(a).should_not be_blank
    end
  end
end

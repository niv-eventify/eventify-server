require File.dirname(__FILE__) + '/../../spec_helper'

describe "/categories/index.html.haml" do
  
  before do
    category_98 = stub_model(Category)
    category_98.should_receive(:name_en).at_least(1).times.and_return("MyString1")
    category_98.should_receive(:name_he).at_least(1).times.and_return("MyString1")
    category_99 = stub_model(Category)
    category_99.should_receive(:name_en).at_least(1).times.and_return("MyString2")
    category_99.should_receive(:name_he).at_least(1).times.and_return("MyString2")

    assigns[:categories] = [category_98, category_99]
  end

  it "should render list of categories" do
    render "/categories/index.html.haml"
    response.should have_tag("tr>td", "MyString1", 2)
    response.should have_tag("tr>td", "MyString2", 2)
  end
end

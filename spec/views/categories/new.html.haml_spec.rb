require File.dirname(__FILE__) + '/../../spec_helper'

describe "/categories/new.html.haml" do
  
  before do
    @category = stub_model(Category)
    @category.stub!(:new_record?).and_return(true)
    @category.stub!(:name_en).and_return("MyString")
    @category.stub!(:name_he).and_return("MyString")
    assigns[:category] = @category
  end

  it "should render new form" do
    render "/categories/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", categories_path) do
      with_tag("input#category_name_en[name=?]", "category[name_en]")
      with_tag("input#category_name_he[name=?]", "category[name_he]")
    end
  end
end

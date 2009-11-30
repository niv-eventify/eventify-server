require File.dirname(__FILE__) + '/../../spec_helper'

describe "/category/edit.html.haml" do
  before do
    @category = stub_model(Category)
    @category.stub!(:name_en).and_return("MyString")
    @category.stub!(:name_he).and_return("MyString")
    assigns[:category] = @category
  end

  it "should render edit form" do
    render "/categories/edit.html.haml"
    
    response.should have_tag("form[action=#{category_path(@category)}][method=post]") do
      with_tag('input#category_name_en[name=?]', "category[name_en]")
      with_tag('input#category_name_he[name=?]', "category[name_he]")
    end
  end
end

require File.dirname(__FILE__) + '/../spec_helper'

describe CategoriesController, "not logged in" do
  [:index, :new, :edit, :destroy, :create, :update].each do |a|
    setup :activate_authlogic
    describe_action(a) do
      before(:each) do
        @params = {:id => 1}
      end
      it_should_require_login
    end
  end
end


describe CategoriesController, "handling GET /categories" do
  setup :activate_authlogic

  before do
    @user = Factory.create(:admin)
    UserSession.create(@user)
    @category = stub_model(Category)
    Category.stub!(:find).and_return([@category])
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all categories" do
    Category.should_receive(:find).with(:all).and_return([@category])
    do_get
  end
  
  it "should assign the found categories for the view" do
    do_get
    assigns[:categories].should == [@category]
  end
end



describe CategoriesController, "handling GET /categories/new" do
  setup :activate_authlogic
  before do
    @user = Factory.create(:admin)
    UserSession.create(@user)
    @category = stub_model(Category)
    Category.stub!(:new).and_return(@category)
  end
  
  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
  
  it "should create an new category" do
    Category.should_receive(:new).and_return(@category)
    do_get
  end
  
  it "should not save the new category" do
    @category.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new category for the view" do
    do_get
    assigns[:category].should equal(@category)
  end
end

describe CategoriesController, "handling GET /categories/1/edit" do
  setup :activate_authlogic
  before do
    @user = Factory.create(:admin)
    UserSession.create(@user)
    @category = stub_model(Category)
    Category.stub!(:find).and_return(@category)
  end
  
  def do_get
    get :edit, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the category requested" do
    Category.should_receive(:find).and_return(@category)
    do_get
  end
  
  it "should assign the found category for the view" do
    do_get
    assigns[:category].should equal(@category)
  end
end

describe CategoriesController, "handling POST /categories" do
  setup :activate_authlogic
  before do
    @user = Factory.create(:admin)
    UserSession.create(@user)
    @category = stub_model(Category, :to_param => "1")
    Category.stub!(:new).and_return(@category)
  end
  
  def post_with_successful_save
    @category.should_receive(:save).and_return(true)
    post :create, :category => {}
  end
  
  def post_with_failed_save
    # @category.should_receive(:save).and_return(false)
    @category.stub!(:new_record?).and_return(true)
    post :create, :category => {}
  end
  
  it "should create a new category" do
    Category.should_receive(:new).with({}).and_return(@category)
    post_with_successful_save
  end

  it "should redirect to the new category on successful save" do
    post_with_successful_save
    response.should redirect_to(categories_url)
  end

  it "should re-render 'new' on failed save" do
    post_with_failed_save
    response.should render_template('new')
  end
end

describe CategoriesController, "handling PUT /categories/1" do
  setup :activate_authlogic
  before do
    @user = Factory.create(:admin)
    UserSession.create(@user)
    @category = stub_model(Category, :to_param => "1")
    Category.stub!(:find).and_return(@category)
  end
  
  def put_with_successful_update
    @category.should_receive(:update_attributes).and_return(true)
    put :update, :id => "1"
  end
  
  def put_with_failed_update
    @category.should_receive(:update_attributes).and_return(false)
    put :update, :id => "1"
  end
  
  it "should find the category requested" do
    Category.should_receive(:find).with("1").and_return(@category)
    put_with_successful_update
  end

  it "should update the found category" do
    put_with_successful_update
    assigns(:category).should equal(@category)
  end

  it "should assign the found category for the view" do
    put_with_successful_update
    assigns(:category).should equal(@category)
  end

  it "should redirect to the category on successful update" do
    put_with_successful_update
    response.should redirect_to(categories_url)
  end

  it "should re-render 'edit' on failed update" do
    put_with_failed_update
    response.should render_template('edit')
  end
end

describe CategoriesController, "handling DELETE /category/1" do
  setup :activate_authlogic
  before do
    @user = Factory.create(:admin)
    UserSession.create(@user)
    @category = stub_model(Category, :destroy => true)
    Category.stub!(:find).and_return(@category)
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the category requested" do
    Category.should_receive(:find).with("1").and_return(@category)
    do_delete
  end
  
  it "should call destroy on the found category" do
    @category.should_receive(:save)
    do_delete
  end
  
  it "should redirect to the categories list" do
    do_delete
    response.should redirect_to(categories_url)
  end
end

ActiveSupport::TestCase.class_eval do
  def stub_pagination(array)
    array.stub!(:total_pages).and_return(1)
  end
end
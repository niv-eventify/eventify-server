ActiveSupport::TestCase.class_eval do
  def stub_time(time = Time.now.utc)
    time.stub!(:utc).and_return(time)
    Time.stub!(:now).and_return(time)
    time
  end
end
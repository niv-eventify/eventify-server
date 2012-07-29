class NetpayLogController < InheritedResources::Base
  actions :create

  def create
    create! do |success, failure|
      success.html {render :nothing => true}
    end
  end
end

class PaymentsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event

  actions :new, :edit, :update

  def new
    build_resource
    resource.set_defaults
  end

protected

  def begin_of_association_chain
    current_user
  end
end

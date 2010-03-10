class PaymentsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event

  actions :create

protected

  def begin_of_association_chain
    current_user
  end

  def collection
    end_of_association_chain
  end
end

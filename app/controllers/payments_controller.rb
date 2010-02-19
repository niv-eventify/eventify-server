class PaymentsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event

  actions :index

  def index
    index! do |success|
      success.html do
        if !@event.payment_required? && @payments.blank?
          redirect_to event_summary_path(@event)
          return
        end
      end
    end
  end


protected

  def begin_of_association_chain
    current_user
  end

  def collection
    end_of_association_chain
  end
end

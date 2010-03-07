class PaymentsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event

  actions :index

  def index
    @event = association_chain.last
    @not_invited_counts = @event.invitations_to_send_counts
  end

protected

  def begin_of_association_chain
    current_user
  end

  def collection
    end_of_association_chain
  end
end

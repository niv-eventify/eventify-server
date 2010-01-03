class GuestsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create

  # index

  def create
    super do |success, failure|
      failure.js do
        render(:update) do |page|
          page[:new_guest].replaceWith render(:partial => "new")
        end
      end
    end
  end

protected
  
  def begin_of_association_chain
    current_user
  end
end

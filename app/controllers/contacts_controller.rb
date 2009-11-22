class ContactsController < InheritedResources::Base
  before_filter :require_user
  actions :new, :edit, :create, :update, :destroy, :index

  def create
    create! {contacts_path}
  end

  def edit
    edit! {contacts_path}
  end

  def update
    update! {contacts_path}
  end

  def destroy
    @contact = end_of_association_chain.find(params[:id])
    @contact.removed_at = Time.now.utc
    @contact.save!
    flash[:notice] = "Contact removed!"
    redirect_to contacts_path
  end

protected

  def collection
    @contacts ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def begin_of_association_chain
    current_user
  end
end

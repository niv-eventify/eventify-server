class ContactImportersController < ApplicationController
  before_filter :require_user
  before_filter :set_importer, :only => [:edit, :update]

  def index
    @contact_importer = current_user.contact_importers.find_by_contact_source(params[:id]) if params[:id]
  end

  def show
    @contact_importer = current_user.contact_importers.find_by_contact_source(params[:id])
    respond_to do |wants|
      wants.html
      wants.js {
        render(:update) do |page|
          unless @contact_importer.completed_at.blank?
            page.redirect_to contact_importer_path(@contact_importer)
          else
            page << check_for_importer_status_js
          end
        end          
      }
    end
  end

  def update
    @contact_importer.attributes = (params[:contact_importer] || {}).merge(:validate_importing => true)

    unless @contact_importer.valid?
      render :action => :index
      return
    end

    if @contact_importer.csv?
      @contact_importer.import!
    else
      @contact_importer.delay.import!(@contact_importer.username, @contact_importer.password)
    end

    redirect_to contact_importer_path(@contact_importer)
  end

protected
  def set_importer
    @contact_importer = current_user.contact_importers.reset_source!(params[:id])
  end
end

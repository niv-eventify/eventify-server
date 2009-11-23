class ContactImportersController < ApplicationController
  before_filter :require_user
  before_filter :set_importer, :only => [:edit, :update]

  def index
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

  def edit
  end

  def update
    return _import_csv if params[:contact_importer] && "csv" == params[:contact_importer][:contact_source]

    _import_from_web
  end

protected
  def set_importer
    @contact_importer = current_user.contact_importers.reset_source!(params[:id])
  end

  def _import_csv
    unless @contact_importer.validate_csv(params[:contact_importer])
      render :action => :edit
      return
    end
    @contact_importer.import!(params)
    redirect_to contact_importer_path(@contact_importer)
  end

  def _import_from_web
    unless @contact_importer.validate_user_password(params[:contact_importer])
      render :action => :edit
      return
    end

    @contact_importer.send_later(:import!, params)
    flash[:notice] = "Importing from #{@contact_importer.name}"

    redirect_to contact_importer_path(@contact_importer)
  end
end

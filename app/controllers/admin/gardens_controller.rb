class Admin::GardensController < InheritedResources::Base
  before_filter :require_admin
  actions :index, :show, :new, :create, :edit, :update, :destroy
end

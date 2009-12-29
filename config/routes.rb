ActionController::Routing::Routes.draw do |map|
  map.activate '/activate/:id', :controller => 'passwords', :action => 'edit'
  map.password_update '/password', :controller => 'passwords', :action => 'update', :conditions => { :method => :put }
  map.password_edit '/password', :controller => 'passwords', :action => 'edit', :conditions => { :method => :get }
  map.resources :passwords, :only => [:new, :create, :edit, :update]
  map.login "/login", :controller => "user_session", :action => "new"
  map.resource :user_session, :controller => "user_session"
  map.signup "/signup", :controller => "users", :action => "new"
  map.resources :users
  map.resource :profile, :controller => "users"
  map.root :controller => "welcome", :action => "index"

  map.resources :pages, :controller => 'pages', :only => [:show]

  map.resources :contacts
  map.resources :contact_importers
  map.resources :categories do |category|
    category.resources :designs
  end
  map.namespace :admin do |admin|
    admin.resources :designs
  end

  map.resources :events
end

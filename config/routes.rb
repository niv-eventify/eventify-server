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
    admin.resources :designers
    admin.resources :users
    admin.resources :events
    admin.resources :gardens
    admin.resources :landing_pages
    admin.resources :links_pages
  end

  map.resources :events do |event|
    event.resources :guests, :collection => {:mass_update => :put}
    event.resources :things
    event.resource :event_maps
    event.resources :payments, :only => [:new, :edit, :update, :create], :member => {:update => :get}
    event.resources :reminders
    event.resource :design
    event.resources :other_guests
    event.resource  :ical, :controller => "ical"
    event.resources :takings
    event.resources :guest_importers
    event.resources :bounces
    event.resources :guests_messages
  end
  map.resources :cancellations
  map.resources :print_invitations
  map.netpay_log "/netpay_log", :controller => :netpay_log, :action => :create

  map.namespace :my do |my|
    my.resources :payments, :only => :index
  end

  map.resources :summary, :controller => "summaries"
  map.resources :invitations
  map.resources :rsvps do |rsvp|
    rsvp.resources :other_guests
    rsvp.resource   :ical, :controller => "ical"
    rsvp.resources :takings
  end
  map.resources :designers, :except => [:show, :edit]
  map.designer_download '/designers/download/:file', :controller => :designers, :action => :download
  map.resources :takings
  map.resources :uploaded_pictures
  map.resources :uploaded_maps
  map.resources :designs do |design|
    design.resources :windows
  end
  map.designer "/designer", :controller => :designers, :action => :edit
  map.lobby "/lobby", :controller => "lobby", :action => "index"
  map.carousel "/carousel.xml", :controller => "welcome", :action => "index", :format => "xml"
  map.resources :cropped_pictures
  map.connect "/1234a3a5e723d2e0fa3e43fbef0c3dac", :controller => :send_grid_events, :action => :create, :conditions => {:method => :post}
  map.resource :links_page
  map.connect '/designers/:friendly_url', :controller => 'designers', :action => 'show'
  map.connect '*friendly_url', :controller => 'landing_pages', :action => 'show'
end

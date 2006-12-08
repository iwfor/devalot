ActionController::Routing::Routes.draw do |map|
  # Named routes
  map.home('', :controller => 'account', :action => 'login')

  # A special case for the project index
  map.project(':project', :controller => 'pages', :action => 'show', :id => 'index')

  # Admin routes
  %W(users roles projects policies).each do |c| 
    map.connect("admin/#{c}/:action/:id", :controller => "admin/#{c}")
  end

  # Generic Routes
  map.connect ':project/:controller/:action/:id.:format'
  map.connect ':project/:controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end

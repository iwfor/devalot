ActionController::Routing::Routes.draw do |map|
  # Named routes
  map.home('', :controller => 'account', :action => 'login')

  # Install the default route as the lowest priority.
  map.connect ':project/:controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end

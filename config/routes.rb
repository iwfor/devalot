ActionController::Routing::Routes.draw do |map|
  # Install the default route as the lowest priority.
  map.connect ':project_slug/:controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end

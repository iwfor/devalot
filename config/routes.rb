ActionController::Routing::Routes.draw do |map|
  # Named routes
  map.home('', :controller => 'home', :action => 'index')

  # Admin routes
  %W(users roles projects policies).each do |c| 
    map.connect("admin/#{c}/:action/:id", :controller => "admin/#{c}")
  end

  # Article Routes
  map.with_options(:controller => 'articles', :action => 'show', :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/) do |url|
    url.connect(':project/:blog/:year/:month/:day/:id')
    url.connect('blogs/:blog/:year/:month/:day/:id')
  end

  # Generic Routes
  map.connect(':controller/:action/:id.:format')
  map.connect(':controller/:action/:id')
  map.connect(':project/:controller/:action/:id.:format')
  map.connect(':project/:controller/:action/:id')
  
  # A special case for the project index
  map.project(':project', :controller => 'pages', :action => 'show', :id => 'index')
end

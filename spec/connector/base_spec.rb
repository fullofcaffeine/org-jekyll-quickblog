require 'spec_helper'

describe FireEngine::Connector::Base do
  
  A connector defines a low-level API connection class that should return and accept Item(s)
  

  
  #list - should return a list of items
  #lookup - should lookup a specific item by an ID/UID
  #add    - should add a new item
  #update - should update the item with params, by ID
  #delete - should remove the item by ID
  
  #should allow user to define the list method:
  
  
  resource_location "/path/to/orgmode/repo"
  #resource_location "url/to/endpoint"
  
  
  
  define :list do |args|
    id "id key" <-- what at
    
    
  end
  
  
  
  #save
  #create
  
end

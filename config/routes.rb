Rails.application.routes.draw do
  # Index page
  root 'application#index'

  # Search related routes
  get '/search', to: 'search#search'
  get 'opensearch.xml', to: 'search#opensearch'

  # Image proxy
  get '/image', to: 'image#proxy'
end

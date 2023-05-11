Rails.application.routes.draw do
  root 'application#index'

  get '/search', to: 'search#search'
end

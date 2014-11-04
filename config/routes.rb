SuggestionsUsingGraph::Application.routes.draw do
  resources :users, :only => [:index, :show]
  resources :following, :only => [:index]
  resources :follows, :only => [:show]

  get '/follow/:id', to: 'users#follow'
  get '/recommendations/:id', to: 'users#recommendations'
  get '/suggest', to: 'following#suggest'
  get '/following/follow/:id', to: 'following#follow'
  get '/following/unfollow/:id', to: 'following#unfollow'

  root 'welcome#index'
end

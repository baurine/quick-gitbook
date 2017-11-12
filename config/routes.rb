Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/',            to: 'books#index'
  get '/:user/:repo', to: 'books#show'
  # only when _book folder not exist will reach this route
  # get '/books/:user/:repo/_book', to: 'books#show'
end

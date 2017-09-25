Rails.application.routes.draw do
  get 'aggregates/list'

  get 'aggregates/:uuid', to: 'aggregates#view'

  get 'filers/list'

  get 'filers/:filername', to: 'filers#view', constraints: { filername: /[^\/]+/ }

  get 'volumes/list'

  get 'filers/:filername/volumes/:volumename', to: 'volumes#view', constraints: { filername: /[^\/]+/ }

  get 'volumes/:id', to: 'volumes#view'

  get 'debug/show'

  get 'test/view'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  get 'volumes/list'

  get 'filers/:filername/volumes/:volumename', to: 'volumes#view', constraints: { filername: /[^\/]+/ }

  get 'debug/show'

  get 'test/view'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

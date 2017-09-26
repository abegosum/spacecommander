Rails.application.routes.draw do
  resources :physical_managers, only: [:index, :show], param: :name, constraints: { name: /[^\/]+/ } do
    resources :aggregates, only: [:index, :show], param: :name
  end

  resources :nodes, only: [:index, :show], param: :name, constraints: { name: /[^\/]+/ } do
    resources :aggregates, only: [:index, :show], param: :name
  end

  resources :aggregates, only: [:index, :show]

  resources :filers, only: [:index, :show], param: :name, constraints: { name: /[^\/]+/ } do
    resources :volumes, only: [:index, :show], param: :name
  end

  resources :volumes, only: [:index, :show]

  get 'debug/show'

  get 'test/view'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

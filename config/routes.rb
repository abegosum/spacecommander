Rails.application.routes.draw do
  get 'charts/node_physical_show/:name', to: 'charts#node_physical_show', constraints: { name: /[^\/]+/ }, as: 'charts_node_physical_show'

  get 'charts/filer_virtual_show/:name', to: 'charts#filer_virtual_show', constraints: { name: /[^\/]+/ }, as: 'charts_filer_virtual_show'

  resources :locations, only: [:index, :show], param: :name

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

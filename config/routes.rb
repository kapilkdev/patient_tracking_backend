Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :members
  resources :opportunities do
    member do
      put 'update_stage', to: 'opportunities#update_stage'
    end
    collection do
      get 'search_by_name_and_procedure'
    end
  end
end

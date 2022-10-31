Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :patients
      post 'authenticate', to: 'authentication#authenticate'
    end
  end
end

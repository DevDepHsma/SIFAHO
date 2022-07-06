Rails.application.routes.draw do
  localized do
    devise_for :users, skip: [:registrations], controllers: { sessions: :sessions }

    resources :permission_requests, except: [:destroy] do
      collection do
        get :request_sectors
        get :request_in_progress
      end
    end

    # Con esta ruta marcamos una notificacion como leida
    post '/notifications/:id/set-as-read', to: 'notifications/notifications#set_as_read', as: 'notifications_set_as_read'

    # Users
    resources :users_admin, controller: :users, only: %i[index update show] do
      member do
        get '/old_permissions', to: 'users#edit_permissions', as: :old_edit_permissions
        put '/old_permissions', to: 'users#update_permissions', as: :old_update_permissions
        put :adds_sector
        delete '/sector/:sector_id', to: 'users#removes_sector', as: :removes_sector
        get :change_sector
        get :permissions, to: 'permissions#index'
        get '/permisos', to: 'permissions#edit', as: :edit_permissions
        put '/permisos', to: 'permissions#update', as: :update_permissions
      end
    end

    # Profiles
    resources :profiles, only: %i[edit update show]
  end
end

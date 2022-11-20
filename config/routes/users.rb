Rails.application.routes.draw do
  localized do
    devise_for :users, skip: [:registrations], controllers: { sessions: :sessions }

    resources :permission_requests, except: %i[edit update create destroy] do
      collection do
        get :request_sectors
        get :request_in_progress
        post '/new', to: 'permission_requests#create', as: :create
      end
    end

    # Con esta ruta marcamos una notificacion como leida
    post '/notifications/:id/set-as-read', to: 'notifications/notifications#set_as_read',
                                           as: 'notifications_set_as_read'

    # Users
    resources :users_admin, controller: :users, only: %i[index update show] do
      member do
        get '/old_permissions', to: 'users#edit_permissions', as: :old_edit_permissions
        put '/old_permissions', to: 'users#update_permissions', as: :old_update_permissions
        put :adds_sector
        delete '/sector/:sector_id', to: 'users#removes_sector', as: :removes_sector
        get :change_sector
        get :permissions_build_from_request, to: 'permissions#build_from_request', as: :build_from_request
        get :permissions_change_sector, to: 'permissions#permission_change_sector', as: :permission_change_sector
        get '/permisos', to: 'permissions#edit', as: :edit_permissions
        put '/permisos', to: 'permissions#update', as: :update_permissions
        put :permissions_build_permission_from_role, to: 'permissions#build_permission_from_role',
                                                     as: :build_permission_from_role
        put 'reject_permission_request/:pr_id', to: 'permissions#reject_permission_request',
                                                as: :reject_permission_request
      end
    end

    # Profiles
    resources :profiles, only: %i[edit update show]
  end
end

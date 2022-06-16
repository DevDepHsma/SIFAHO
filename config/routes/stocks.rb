Rails.application.routes.draw do
  localized do
    # Stocks
    resources :stocks, only: %i[index show] do
      collection do
        resources :lot_stocks, only: %i[index show] do
          member do
            resources :lot_archives, only: %i[show new create]
          end
        end
      end
      # collection do
      #   get '/lotes', to: 'lot_stocks#index', as: :lot_stocks_index
      # end
      get '/lotes', to: 'lot_stocks#lot_stocks_by_stock', as: :lot_stocks_by_stock
      get '/lotes/:lot_stock_id/', to: 'lot_stocks#show', as: :show_lot_stocks
      get '/lotes/:lot_stock_id/new_archive', to: 'lot_stocks#new_archive', as: :new_archive
      post '/lotes/:lot_stock_id/create_archive', to: 'lot_stocks#create_archive', as: :create_archive

      member do
        resources :stock_movements, only: :index
      end
    end

    get ':id/return_archive_modal', to: 'lot_stocks#return_archive_modal', as: :return_archive_modal

    # get 'lot_archive/:id', to: 'lot_stocks#show_lot_archive', as: :lot_archive
    patch ':id/return_archive', to: 'lot_stocks#return_archive', as: :return_archive

    # Lots
    resources :lots do
      member do
        get :delete
      end
      collection do
        get :search_by_code
        resources :lot_provenances
      end
    end

    # Sector supply lots
    resources :sector_supply_lots, only: %i[index show create destroy] do
      member do
        get :delete
        get :restore
        get :restore_confirm
        get :purge
        get :purge_confirm
        get :archive
        get :archive_confirm
        get :lots_for_supply
      end
      collection do
        get :select_lot
        get :trash_index
        get :group_by_supply
        get :get_stock_quantity
        get :search_by_code
        get :search_by_name
      end
    end
  end
end

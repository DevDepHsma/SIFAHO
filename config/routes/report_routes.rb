Rails.application.routes.draw do
  # Reports
  localized do
    resources :reports, only: %i[index new create show destroy] do
      collection do
        get :get_stock_products, to: 'reports#get_stock_products', as: 'get_stock_products'
        get 'select_product/:product_id', to: 'reports#select_product', as: 'select_product'
        get 'unselect_product/:product_id', to: 'reports#unselect_product', as: 'unselect_product'

        get :get_patients_by_sector, to: 'reports#get_patients_by_sector', as: 'get_patients_by_sector'
        get :get_sectors, to: 'reports#get_sectors', as: 'get_sectors'
        get 'select_patient/:patient_id', to: 'reports#select_patient', as: 'select_patient'
        get 'unselect_patient/:patient_id', to: 'reports#unselect_patient', as: 'unselect_patient'
        get 'select_sector/:sector_id', to: 'reports#select_sector', as: 'select_sector'
        get 'unselect_sector/:sector_id', to: 'reports#unselect_sector', as: 'unselect_sector'
      end
    end
    # State reports
    namespace :state_reports do
      resources :patient_product_state_reports,
                only: %i[show new create],
                controller: :patient_product_state_reports,
                model: :patient_product_state_report do
        collection do
          get :load_more
        end
      end
    end
  end
end

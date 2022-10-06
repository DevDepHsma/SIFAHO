Rails.application.routes.draw do
  # Reports
  localized do
    resources :reports, only: %i[index new create show destroy] do
      collection do
        get :get_stock_products, to: 'reports#get_stock_products', as: 'get_stock_products'
        get 'select_product/:product_id', to: 'reports#select_product', as: 'select_product'
        get 'unselect_product/:product_id', to: 'reports#unselect_product', as: 'unselect_product'

        get :get_patients_by_sector, to: 'reports#get_patients_by_sector', as: 'get_patients_by_sector'
        get 'select_patient/:patient_id', to: 'reports#select_patient', as: 'select_patient'
        get 'unselect_patient/:patient_id', to: 'reports#unselect_patient', as: 'unselect_patient'
      end
    end
  end
end

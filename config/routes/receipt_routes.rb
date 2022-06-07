Rails.application.routes.draw do
  localized do
    # Recibos
    resources :receipts do
      member do
        patch :rollback_order
        get :delete
      end
    end
  end
end

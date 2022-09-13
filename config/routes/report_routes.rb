Rails.application.routes.draw do
  # Reports
  localized do
    scope module: :reports, path: :reports do
      # namespace :reports do
      # collection do
      # # Internal order product report
      # resources :internal_order_product_reports,
      #           only: %i[show new create],
      #           controller: :internal_order_products,
      #           model: :internal_order_prodcut_reports

      # External order product report
      # resources :external_order_product_reports,
      #           only: %i[show new create],
      #           controller: :external_order_products,
      #           model: :external_order_prodcut_reports

      # # Stock quantity report
      # resources :stock_quantity_reports,
      #           only: %i[show new create],
      #           controller: :stock_quantity_reports,
      #           model: :stock_quantity_reports

      # Monthly consumption report
      # resources :monthly_consumption_reports,
      #           only: %i[show new create],
      #           controller: :monthly_consumption_reports,
      #           model: :monthly_consumption_reports

      # Patient product report
      # resources :patient_product_reports,
      #           only: %i[show new create],
      #           controller: :patient_product_reports,
      #           model: :patient_product_reports

      # review
      # resources :index_reports, only: [:index]

      # review
      # resources :reports, only: %i[show index]
      # end

      # State reports
      # namespace :state_reports do
      #   resources :patient_product_state_reports,
      #             only: %i[show new create],
      #             controller: :patient_product_state_reports,
      #             model: :patient_product_state_report do
      #     collection do
      #       get :load_more
      #     end
      #   end
      # end
      # end
    end
    resources :reports, only: %i[index new create]
  end
end

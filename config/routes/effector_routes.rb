Rails.application.routes.draw do
  localized do
    # Patients
    resources :patients do
      collection do
        get :search
        get :get_by_dni_and_fullname
        get :get_by_dni
        get :get_by_fullname
      end
    end

    # Professionals
    resources :professionals do
      member do
        get :restore
        get :restore_confirm
      end
      collection do
        get :doctors
        get :get_by_enrollment_and_fullname_html
        get :get_by_enrollment_and_fullname
        get :get_by_unsigned_enrollment_fullname
        post :asign_user
      end
    end

    # Laboratories
    resources :laboratories do
      collection do
        get :search_by_name
      end
    end
  end
end

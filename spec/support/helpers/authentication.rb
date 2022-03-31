module Helpers
  module Authentication
    def sign_in_as(user)
      visit '/users/sign_in'
      within('#new_user') do
        fill_in 'user_username', with: user.username
        fill_in 'user_password', with: user.password
      end
      click_button 'Iniciar sesión'
    end
  end
end
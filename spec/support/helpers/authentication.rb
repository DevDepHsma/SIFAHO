module Helpers
  module Authentication
    def sign_in_as(user)
      visit new_user_session_path
      within('#new_user') do
        fill_in 'user_username', with: user.username
        fill_in 'user_password', with: user.password
      end
      click_button 'Iniciar sesión'
    end

    def sign_out_as(user)
      expect(page.has_button?("#{user.sector_name} #{user.sector_establishment_short_name}")).to be true
      click_button "#{user.sector_name} #{user.sector_establishment_short_name}"
      click_link 'Cerrar sesión'
    end
  end
end

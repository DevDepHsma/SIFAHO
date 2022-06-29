require 'rails_helper'

RSpec.feature 'Users', type: :feature, js: true do

  before(:all) do
    @req_user = create(:user_5)
  end

  background do
    sign_in_as(@req_user)
  end

  describe '' do
    subject { page }

    it 'After login - redirect to permission request form' do
      expect(page).to have_content('Solicitud de permisos')
      expect(page).to have_content('Complete el formulario para comenzar a utilizar el sistema.')
      expect(page).to have_content(@req_user.profile.full_name.to_s)
      expect(page).to have_content(@req_user.profile.dni)
      expect(page.has_css?('#establishment', visible: false)).to be true
      expect(page.has_css?('#sector', visible: false)).to be true
      expect(page).to have_content('Dispensar recetas')
      expect(page).to have_content('Ordenes internas')
      expect(page).to have_content('Ordenes externas')
      expect(page).to have_content('Recibos')
      expect(page).to have_content('Reportes')
    end
  end
end

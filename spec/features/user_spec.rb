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

    after(:each) do
      pr = PermissionRequest.find_by(user_id: @req_user.id)
      pr.destroy if pr.present?
    end

    it 'Permission request form: exists establishment and sector' do
      expect(page).to have_content('Solicitud de permisos')
      expect(page).to have_content('Complete el formulario para comenzar a utilizar el sistema.')
      expect(page.has_button?('Enviar')).to be true
      expect(page.has_css?('#permission_request_establishment_id', visible: false)).to be true

      within '#new_permission_request' do
        page.execute_script %Q{
          const button = $('select#permission_request_establishment_id').next('button');
          button.click();
          button.next('.dropdown-menu').find('input').first().val('carrillo').trigger('propertychange');
          button.next('.dropdown-menu').find('a.dropdown-item').first().click();
        }
        sleep 1
        page.execute_script %Q{
          const button = $('select#permission_request_sector_id').next('button');
          button.click();
          button.next('.dropdown-menu').find('input').first().val('farmacia').trigger('propertychange');
          button.next('.dropdown-menu').find('a.dropdown-item').first().click();
        }
        sleep 1
        fill_in 'permission_request_observation', with: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. "
      end
      click_button 'Enviar'
      expect(page).to have_content('Solicitud enviada.')
      expect(page).to have_content('Espere una respuesta')
      expect(page).to have_content('El equipo de gestión evaluará su solicitud y tomará las medidas correspondientes.')
    end

    it 'Permission request form: none establishment' do
      expect(page).to have_content('Solicitud de permisos')
      expect(page).to have_content('Complete el formulario para comenzar a utilizar el sistema.')
      expect(page.has_button?('Enviar')).to be true
      expect(page.has_css?('#permission_request_establishment_id', visible: false)).to be true

      within '#new_permission_request' do
        page.execute_script %Q{
          const button = $('select#permission_request_establishment_id').next('button');
          button.click();
          button.next('.dropdown-menu').find('input').first().val('otro').trigger('propertychange');
          button.next('.dropdown-menu').find('a.dropdown-item').first().click();
        }
        sleep 1
        expect(page.has_css?('#permission_request_establishment')).to be true 
        expect(page.has_css?('#permission_request_sector')).to be true 

        sleep 1
        fill_in 'permission_request_establishment', with: "Hospital Zonal Zapala"
        fill_in 'permission_request_sector', with: "Farmacia"
        fill_in 'permission_request_observation', with: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. "
      end
      click_button 'Enviar'
      expect(page).to have_content('Solicitud enviada.')
      expect(page).to have_content('Espere una respuesta')
      expect(page).to have_content('El equipo de gestión evaluará su solicitud y tomará las medidas correspondientes.')
    end
    # sleep 10
    # expect(find('ul.ui-autocomplete')).to have_content(product[1].to_s)
    # page.execute_script("$('.ui-menu-item:contains(#{product[1]})').first().click()")

    # expect(page.has_css?('#sector', visible: false)).to be true
    # expect(page).to have_content('Dispensar recetas')
    # expect(page).to have_content('Ordenes internas')
    # expect(page).to have_content('Ordenes externas')
    # expect(page).to have_content('Recibos')
    # expect(page).to have_content('Reportes')
  end
end

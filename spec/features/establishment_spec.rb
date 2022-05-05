require 'rails_helper'

RSpec.feature "Establishments", type: :feature do
  before(:all) do
    @permission_module = create(:permission_module, name: 'Establecimientos')
    @read_establishments = create(:permission, name: 'read_establishments', permission_module: @permission_module)
    @create_establishments = create(:permission, name: 'create_establishments', permission_module: @permission_module)
    @update_establishments = create(:permission, name: 'update_establishments', permission_module: @permission_module)
    @destroy_establishments = create(:permission, name: 'destroy_establishments', permission_module: @permission_module)
  end

  background do
    sign_in_as(@user)
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe "Add permission:" do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_establishments)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Establecimientos')).to be true
          click_link 'Establecimientos'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Establecimientos')).to be true
        end

        within '#establishments' do
          expect(page).to have_selector('.btn-detail', count: 2)
          page.execute_script %Q{$('a.btn-detail')[0].click()}
        end
        expect(page).to have_content('Viendo establecimiento')
        expect(page).to have_content('Información')
        expect(page).to have_content('Ubicación')
        expect(page).to have_content('Sectores')
        expect(page).to have_content('Usuarios')
        expect(page.has_link?('Volver')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @create_establishments)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Agregar')).to be true
          click_link 'Agregar'
        end

        expect(page.has_css?('#establishment_name')).to be true
        expect(page.has_css?('#establishment_short_name')).to be true
        expect(page.has_css?('#sanitary_zone', visible: false)).to be true
        expect(page.has_css?('#establishment_type', visible: false)).to be true
        within '#new_establishment' do
          fill_in 'establishment_name', with: 'Hospital Villa La Angostura'
          fill_in 'establishment_short_name', with: 'HVLA'
          click_button 'Seleccionar zona sanitaria'
          find('button', text: 'Seleccionar zona sanitaria').sibling('div', class: 'dropdown-menu').find('a', text: 'Zona Sanitaria IV').click
          click_button 'Seleccionar tipo'
          find('button', text: 'Seleccionar tipo').sibling('div', class: 'dropdown-menu').find('a', text: 'Hospital').click
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#establishments' do
          expect(page).to have_selector('.btn-detail', count: 3)
        end
        PermissionUser.create(user: @user, sector: @user.sector, permission: @update_establishments)
        visit current_path
        within '#establishments' do
          expect(page).to have_selector('.btn-edit', count: 3)
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end
        expect(page).to  have_content('Editando establecimiento')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_establishments)
        visit current_path
        within '#establishments' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar establecimiento')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#establishments' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end

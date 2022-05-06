require 'rails_helper'

RSpec.feature 'Sectors', type: :feature do
  require 'rails_helper'

  before(:all) do
    @permission_module = create(:permission_module, name: 'Sectores')
    @read_sectors = create(:permission, name: 'read_sectors', permission_module: @permission_module)
    @create_sectors = create(:permission, name: 'create_sectors', permission_module: @permission_module)
    @update_sectors = create(:permission, name: 'update_sectors', permission_module: @permission_module)
    @destroy_sectors = create(:permission, name: 'destroy_sectors', permission_module: @permission_module)
    @select_establishment = create(:permission, name: 'create_to_other_establishment', permission_module: @permission_module)
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
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_sectors)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Sectores')).to be true
          click_link 'Sectores'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Sectores')).to be true
        end

        within '#sectors' do
          expect(page).to have_selector('.btn-detail')
          sleep 10
          page.execute_script %Q{$('a.btn-detail')[0].click()}
        end
        expect(page).to have_content('Viendo sector')
        expect(page).to have_content('Establecimiento')
        expect(page).to have_content('Descripción')
        expect(page).to have_content('Usuarios')
        expect(page.has_link?('Volver')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @create_sectors)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Crear sector')).to be true
          click_link 'Crear sector'
        end

        sleep 10
        expect(page.has_css?('#sector_name')).to be true
        expect(page.has_css?('#sector_description')).to be true
        expect(page).to have_content(@user.sector.establishment.name)
        expect(page.has_css?('#sector_establishment_id')).to be false
        PermissionUser.create(user: @user, sector: @user.sector, permission: @select_establishment)
        visit current_path
        expect(page.has_css?('#sector_establishment_id', visible: false)).to be true
        sleep 10
        within '#new_establishment' do
          fill_in 'sector_name', with: 'Hospital Villa La Angostura'
          fill_in 'establishment_short_name', with: 'HVLA'
          click_button 'Seleccionar zona sanitaria'
          find('button', text: 'Seleccionar zona sanitaria').sibling('div', class: 'dropdown-menu').find('a', text: 'Zona Sanitaria IV').click
          click_button 'Seleccionar tipo'
          find('button', text: 'Seleccionar tipo').sibling('div', class: 'dropdown-menu').find('a', text: 'Hospital').click
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#sectors' do
          expect(page).to have_selector('.btn-detail', count: 3)
        end
        PermissionUser.create(user: @user, sector: @user.sector, permission: @update_sectors)
        visit current_path
        within '#sectors' do
          expect(page).to have_selector('.btn-edit', count: 3)
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end
        expect(page).to  have_content('Editando establecimiento')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_sectors)
        visit current_path
        within '#sectors' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar establecimiento')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#sectors' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end


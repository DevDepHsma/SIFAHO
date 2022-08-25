require 'rails_helper'

RSpec.feature 'Sectors', type: :feature do
  require 'rails_helper'

  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Sectores')
    @read_sectors = permission_module.permissions.find_by(name: 'read_sectors')
    @create_sectors = permission_module.permissions.find_by(name: 'create_sectors')
    @update_sectors = permission_module.permissions.find_by(name: 'update_sectors')
    @destroy_sectors = permission_module.permissions.find_by(name: 'destroy_sectors')
    @select_establishment = permission_module.permissions.find_by(name: 'create_to_other_establishment')
    @read_other_establishments = permission_module.permissions.find_by(name: 'read_other_establishments')
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe 'Add permission:' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_sectors)
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
          page.execute_script %{$('a.btn-detail')[0].click()}
        end
        expect(page).to have_content('Viendo sector')
        expect(page).to have_content('Establecimiento')
        expect(page).to have_content('Descripción')
        expect(page).to have_content('Usuarios')
        expect(page.has_link?('Volver')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_sectors)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Crear sector')).to be true
          click_link 'Crear sector'
        end
        expect(page.has_css?('#sector_name')).to be true
        expect(page.has_css?('#sector_description')).to be true
        expect(page).to have_content(@farm_applicant.sector.establishment.name)
        expect(page.has_css?('#sector_establishment_id')).to be false
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @select_establishment)
        visit current_path
        expect(page.has_css?('#sector_establishment_id', visible: false)).to be true
        within '#new_sector' do
          fill_in 'sector_name', with: 'Cocina'
        end
        click_button 'Guardar'
        click_link 'Volver'
        sleep 1
        within '#sectors' do
          expect(page).to have_selector('.btn-detail')
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_sectors)
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                              permission: @read_other_establishments)
        visit current_path
        within '#sectors' do
          expect(page).to have_selector('.btn-edit')
          page.execute_script %{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando sector')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_sectors)
        visit current_path
        within '#sectors' do
          expect(page).to have_selector('.delete-item')
          page.execute_script %{$('td:contains("Cocina")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar sector')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
      end
    end
  end
end

require 'rails_helper'

RSpec.feature 'SanitaryZones', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Zonas Sanitarias')
    @read_sanitary_zones = permission_module.permissions.find_by(name: 'read_sanitary_zones')
    @create_sanitary_zones = permission_module.permissions.find_by(name: 'create_sanitary_zones')
    @update_sanitary_zones = permission_module.permissions.find_by(name: 'update_sanitary_zones')
    @destroy_sanitary_zones = permission_module.permissions.find_by(name: 'destroy_sanitary_zones')
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe 'Add permission:' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_sanitary_zones)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Zonas sanitarias')).to be true
          click_link 'Zonas sanitarias'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Zonas sanitarias')).to be true
        end

        within '#sanitary_zones' do
          expect(page).to have_selector('.btn-detail')
          page.execute_script %{$('a.btn-detail')[0].click()}
        end
        expect(page).to have_content('Viendo zona sanitaria')
        expect(page).to have_content('Zona')
        expect(page).to have_content('Provincia')
        expect(page.has_link?('Volver')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @create_sanitary_zones)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Agregar')).to be true
          click_link 'Agregar'
        end
        expect(page.has_css?('#sanitary_zone_name')).to be true
        expect(page.has_css?('#sanitary_zone_state_id', visible: false)).to be true
        within '#new_sanitary_zone' do
          fill_in 'sanitary_zone_name', with: 'Zona sanitaria III'
          page.execute_script %{
              $('#sanitary_zone_state_id').siblings('button.dropdown-toggle').first().click()
            }
          page.execute_script %{
              $('dropdown-menu').first().find('input').val("Neuquén");
              $('a:contains(Neuquén)').click()
            }
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#sanitary_zones' do
          expect(page).to have_selector('.btn-detail')
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @update_sanitary_zones)
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_other_establishments)
        visit current_path
        within '#sanitary_zones' do
          expect(page).to have_selector('.btn-edit')
          page.execute_script %{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando zona sanitaria')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @destroy_sanitary_zones)
        visit current_path
        within '#sanitary_zones' do
          expect(page).to have_selector('.delete-item')
          page.execute_script %{$('td:contains("Zona sanitaria III")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar zona sanitaria')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
      end
    end
  end
end

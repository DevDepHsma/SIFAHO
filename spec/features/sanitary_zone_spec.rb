require 'rails_helper'

RSpec.feature "SanitaryZones", type: :feature do  
    before(:all) do
      @permission_module = create(:permission_module, name: 'Zonas Sanitarias')
      @read_sanitary_zones = create(:permission, name: 'read_sanitary_zones', permission_module: @permission_module)
      @create_sanitary_zones = create(:permission, name: 'create_sanitary_zones', permission_module: @permission_module)
      @update_sanitary_zones = create(:permission, name: 'update_sanitary_zones', permission_module: @permission_module)
      @destroy_sanitary_zones = create(:permission, name: 'destroy_sanitary_zones', permission_module: @permission_module)
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
          PermissionUser.create(user: @user, sector: @user.sector, permission: @read_sanitary_zones)
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
            page.execute_script %Q{$('a.btn-detail')[0].click()}
          end
          expect(page).to have_content('Viendo zona sanitaria')
          expect(page).to have_content('Zona')
          expect(page).to have_content('Provincia')
          expect(page.has_link?('Volver')).to be true
          click_link 'Volver'
          PermissionUser.create(user: @user, sector: @user.sector, permission: @create_sanitary_zones)
          visit current_path
          within '#dropdown-menu-header' do
            expect(page.has_link?('Agregar')).to be true
            click_link 'Agregar'
          end
          expect(page.has_css?('#sanitary_zone_name')).to be true
          expect(page.has_css?('#sanitary_zone_state_id', visible: false)).to be true
          within '#new_sanitary_zone' do
            fill_in 'sanitary_zone_name', with: 'Zona sanitaria III'
            page.execute_script %Q{
              $('#sanitary_zone_state_id').siblings('button.dropdown-toggle').first().click()
            }
            page.execute_script %Q{
              $('dropdown-menu').first().find('input').val("Neuquén");
              $('a:contains(Neuquén)').click()
            }
          end
          click_button 'Guardar'
          click_link 'Volver'
          within '#sanitary_zones' do
            expect(page).to have_selector('.btn-detail', count: 2)
          end
          PermissionUser.create(user: @user, sector: @user.sector, permission: @update_sanitary_zones)
          PermissionUser.create(user: @user, sector: @user.sector, permission: @read_other_establishments)
          visit current_path
          within '#sanitary_zones' do
            expect(page).to have_selector('.btn-edit', count: 2)
            page.execute_script %Q{$('a.btn-edit')[0].click()}
          end
          expect(page).to  have_content('Editando zona sanitaria')
          expect(page.has_link?('Volver')).to be true
          expect(page.has_button?('Guardar')).to be true
          click_link 'Volver'
          PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_sanitary_zones)
          visit current_path
          within '#sanitary_zones' do
            expect(page).to have_selector('.delete-item', count: 1)
            page.execute_script %Q{$('td:contains("Zona sanitaria III")').closest('tr').find('button.delete-item').click()}
          end
          sleep 1
          expect(page).to have_content('Eliminar zona sanitaria')
          expect(page.has_button?('Volver')).to be true
          expect(page.has_link?('Confirmar')).to be true
          click_link 'Confirmar'
          sleep 1
          within '#sanitary_zones' do
            expect(page).to have_selector('.delete-item', count: 0)
          end
        end
      end
    end
  end
  
  
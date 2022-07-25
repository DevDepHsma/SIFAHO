require 'rails_helper'

RSpec.feature 'Users', type: :feature, js: true do
  before(:all) do
    @permission_module = create(:permission_module, name: 'Usuarios')
    @read_users = create(:permission, name: 'read_users', permission_module: @permission_module)
    @answer_permission_request = create(:permission, name: 'answer_permission_request', permission_module: @permission_module)
    @update_permissions = create(:permission, name: 'update_permissions', permission_module: @permission_module)
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
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_users)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Usuarios')).to be true
          click_link 'Usuarios'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Usuarios')).to be true
          expect(page.has_link?('Solicitud de permisos')).to be false
        end
        # Permission Request list
        PermissionUser.create(user: @user, sector: @user.sector, permission: @answer_permission_request)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Solicitud de permisos')).to be true
          click_link 'Solicitud de permisos'
        end
        user_requested = create(:user_6)
        create(:permission_req_1, user: user_requested)
        visit current_path
        # Answer request
        within '#permission_requests' do
          expect(page).to have_selector('tr', count: 1)
          page.execute_script %Q{$('tr.info')[0].click()}
        end
        expect(page).to have_content('Solicitud de permisos en progreso')
        expect(page.has_css?('#permission_req_in_progress')).to be true
        expect(page.has_button?('Cerrar')).to be true
        click_button 'Cerrar'
        sleep 1
        find('#open-sectors-select-modal').click
        sleep 1
        expect(page).to have_content('Selección de sectores')
        expect(page).to have_content('Sectores activos')
        expect(page.has_button?('Cerrar')).to be true
        # Assign Establishment & sector
        page.execute_script %Q{
          const button = $('select#remote_form_sector_selector').next('button');
          button.click();
          button.next('.dropdown-menu').find('input').first().val('carrillo').trigger('propertychange');
          button.next('.dropdown-menu').find('a.dropdown-item').first().click();
        }
        click_button 'Cerrar'
        sleep 1
        # Set user list permission
        page.execute_script %Q{
          $('input#remote_form_search_name').val('Usuario').keyup();
        }
        sleep 1
        page.execute_script %Q{
          $('label:contains("Ver / Listar")').click();
        }
        sleep 1
        click_button 'Guardar'
        expect(page).to have_content('Viendo usuario')
        expect(page).to have_content('Sectores habilitados')
        sign_out_as(@user)
        sleep 1
        # Sign in as user_requested and check user list permission
        sign_in_as(user_requested)

        expect(page.has_link?('Usuarios')).to be true
        expect(page).to have_content('Depósito')
        sign_out_as(user_requested)
        sleep 1
        # Edit user_requested permissions
        sign_in_as(@user)

        within '#sidebar-wrapper' do
          click_link 'Usuarios'
        end

        expect(page).to have_content(user_requested.username.to_s)
        expect(page).not_to have_selector('a.btn-permission-edit')
        PermissionUser.create(user: @user, sector: @user.sector, permission: @update_permissions)
        visit current_path
        expect(page).to have_selector('a.btn-permission-edit')

        page.execute_script %Q{
          const tr = $('td:contains("#{user_requested.username}")').closest('tr');
          tr.find('a.btn-permission-edit')[0].click();
        }
        expect(page).to have_content('Editando permisos')
        within '#page-content-wrapper' do
          expect(page).not_to have_content('Solicitud de permisos')
        end
        # Remove sector to user_requested
        find('#open-sectors-select-modal').click
        sleep 1
        within '#select_sector_container' do
          page.execute_script %Q{
            $('button.delete-item').first().click();
          }
        end
        sleep 1
        within '#delete-item' do
          click_link 'Confirmar'
        end
        sleep 1
        within '#sector-selection' do
          click_button 'Cerrar'
        end
        sleep 1
        sign_out_as(@user)
        sleep 1
        sign_in_as(user_requested)
        # User with more than 1 permission_request
        expect(page).to have_content('Debe solicitar un establecimiento y sector aquí.')
      end
    end
  end
end

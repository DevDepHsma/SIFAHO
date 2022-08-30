require 'rails_helper'

RSpec.feature 'Users', type: :feature, js: true do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Usuarios')
    @read_users = permission_module.permissions.find_by(name: 'read_users')
    @answer_permission_request = permission_module.permissions.find_by(name: 'answer_permission_request')
    @update_permissions = permission_module.permissions.find_by(name: 'update_permissions')
    @user_requested = create(:user_1)
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe "Add permission:" do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_users)
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
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @answer_permission_request)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Solicitud de permisos')).to be true
          click_link 'Solicitud de permisos'
        end
        role = Role.first
        create(:permission_request, user: @user_requested, roles: [role])
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
        expect(page).to have_content('Permisos asignados correctamente.')
        sign_out_as(@farm_applicant)
        sleep 1
        # Sign in as @user_requested and check user list permission
        @user_requested = User.find(@user_requested.id)
        @user_requested.password = 'password'
        sign_in_as(@user_requested)
        expect(page.has_link?('Usuarios')).to be true
        expect(page).to have_content('Depósito')
        expect(@user_requested.active?).to be true
        sign_out_as(@user_requested)
        sleep 1
        # Edit @user_requested permissions
        sign_in_as(@farm_applicant)

        within '#sidebar-wrapper' do
          click_link 'Usuarios'
        end
        expect(page).to have_content(@user_requested.username.to_s)
        expect(page).not_to have_selector('a.btn-permission-edit')
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_permissions)
        visit current_path
        expect(page).to have_selector('a.btn-permission-edit')

        page.execute_script %Q{
          const tr = $('td:contains("#{@user_requested.username}")').closest('tr');
          tr.find('a.btn-permission-edit')[0].click();
        }
        expect(page).to have_content('Editando permisos')
        within '#page-content-wrapper' do
          expect(page).not_to have_content('Solicitud de permisos')
        end
        # Remove sector to @user_requested
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
        sign_out_as(@farm_applicant)
        sleep 1
        sign_in_as(@user_requested)
        # User with more than 1 permission_request
        expect(page).to have_content('Debe solicitar un establecimiento y sector aquí.')
        expect(page.has_link?('aquí.')).to be true
        click_link 'aquí.'
        expect(page).to have_content('Solicitud de permisos')
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
          role = get_roles.sample
          page.execute_script %Q{
            $('label:contains("#{role}")').first().click()
          }
          fill_in 'permission_request_observation', with: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. "
        end
        click_button 'Enviar'
        expect(page).to have_content('Solicitud enviada.')
        expect(page).to have_content('Espere una respuesta')
        expect(page).to have_content('El equipo de gestión evaluará su solicitud y tomará las medidas correspondientes.')
        @user_requested = User.find(@user_requested.id)
        expect(@user_requested.permission_req?).to be true
      end
    end
  end
end

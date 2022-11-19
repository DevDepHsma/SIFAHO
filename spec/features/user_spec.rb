#  Test information

#  Testing modules:
#  Access permissions: List / Show / Request Permission show / Edit Permission
#  Present fields and values on edit
#  Save user
#  Validations on empty form
#  Check present fields values on Save fails
#

require 'rails_helper'

RSpec.feature 'Users', type: :feature, js: true do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Usuarios')
    @read_users = permission_module.permissions.find_by(name: 'read_users')
    @answer_permission_request = permission_module.permissions.find_by(name: 'answer_permission_request')
    @update_permissions = permission_module.permissions.find_by(name: 'update_permissions')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_users)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @answer_permission_request)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_permissions)

    @user_permission_requested = @users_permission_requested.sample
    @permission_request = PermissionRequest.where(user_id: @user_permission_requested.id).first
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    describe 'Permission:' do
      it 'List' do
        visit '/'
        expect(page).to have_css('#sidebar-wrapper', visible: false)
        within '#sidebar-wrapper' do
          expect(page).to have_link('Usuarios')
          click_link 'Usuarios'
        end
        within '#dropdown-menu-header' do
          expect(page).to have_link('Usuarios')
        end
      end

      it 'Show' do
        visit '/usuarios'
        within '#users' do
          expect(page).to have_css('.btn-detail')
        end
        user = User.all.sample
        visit "/usuarios/#{user.id}"
        expect(page).to have_content("Viendo usuario #{user.full_name.titleize}")
        expect(page).to have_content('Sector actual')
        expect(page).to have_content('Sectores habilitados')
        expect(page).to have_content('DNI')
        expect(page).to have_content(user.profile.dni)
        expect(page).to have_link('Volver')
        expect(page).to have_link('Editar')
      end

      it 'Request Permissions list' do
        visit '/usuarios'
        within '#dropdown-menu-header' do
          expect(page).to have_link('Solicitud de permisos')
          click_link 'Solicitud de permisos'
        end
        expect(page).to have_css('#permission_requests')
      end

      it 'Edit permissions' do
        visit "/usuarios/#{@user_permission_requested.id}/permisos"

        expect(page).to have_content('Solicitud de permisos en progreso')
        expect(page).to have_button('Agregar sector')
        expect(page).to have_content('Nueva solicitud de permisos:')
        expect(page).to have_content("Establecimiento indicado: #{@permission_request.establishment.name}")
        expect(page).to have_content("Sector indicado: #{@permission_request.sector.name}")
        expect(page).to have_content('Funciones seleccionadas:')
        expect(page).to have_content('Observaciones')
        expect(page).to have_button('Anular')
        expect(page).to have_link('Aplicar')
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
      end

      it 'Edit permissions apply permission request' do
        visit "/usuarios/#{@user_permission_requested.id}/permisos"

        click_link 'Aplicar'
        sleep 1
        within '#location_select_container' do
          expect(page).to have_link("#{@permission_request.sector.name} - #{@permission_request.establishment.name}")
          expect(page).to have_content('Modulos')
          Role.all.each do |role|
            expect(page).to have_field("role-#{role.id}", type: 'checkbox', visible: false)
          end

          @permission_request.roles.all.each do |role|
            expect(page).to have_field("role-#{role.id}", type: 'checkbox', visible: false, checked: true)
          end
        end

        within '#permissions_list' do
          expect(page).to have_field('permission[search_name]')
          @permission_request.roles.each do |role|
            role.permissions.each do |permission|
              expect(page).to have_field("permission[permission_users_attributes][#{permission.id}][permission_id]",
                                         type: 'checkbox', visible: false, checked: true)
            end
          end
        end
      end
    end

    describe 'Form' do
      it 'Search by module input' do
        visit "/usuarios/#{@user_permission_requested.id}/permisos"
        click_link 'Aplicar'

        fill_in 'permission[search_name]', with: 'usua'
        within '#permission_users' do
          expect(page).to have_button('Usuario')
        end

        fill_in 'permission[search_name]', with: 'sto'
        within '#permission_users' do
          expect(page).to have_button('Stock')
        end
      end

      it 'Save successfully permissions' do
        permission_requested_to_approve = @users_permission_requested.where.not(id: @user_permission_requested.id).sample
        visit "/usuarios/#{permission_requested_to_approve.id}/permisos"
        click_link 'Aplicar'
        sleep 1
        click_button 'Guardar'
        expect(page).to have_content('Permisos asignados correctamente.')
      end

      it 'validate empty form sent' do
        visit "/usuarios/#{@user_permission_requested.id}/permisos"
        click_button 'Guardar'
        expect(page).to have_content('Debe seleccionar un sector valido')
      end

      it 'anular' do
      end

      it 'shows add sector modal' do
        visit "/usuarios/#{@user_permission_requested.id}/permisos"
        click_button 'Agregar sector'
        sleep 1
        expect(page).to have_selector('#sector-selection', visible: true)
        expect(page).to have_content('Selección de sectores')
        expect(page).to have_select('remote_form[sector]', visible: false)
        expect(page).to have_button('Cerrar')
      end

      it 'adds sector' do
        visit "/usuarios/#{@user_permission_requested.id}/permisos"
        click_button 'Agregar sector'
        sleep 1
        find('select#remote_form_sector_selector + button').click
        expect(page).to have_selector('a', text: "#{@depo_est_1.name} - #{@depo_est_1.establishment.name}")
        find('a', text: "#{@depo_est_1.name} - #{@depo_est_1.establishment.name}").click
        sleep 1
        within '#location_select_container' do
          expect(page).to have_selector('a', text: "#{@depo_est_1.name} - #{@depo_est_1.establishment.name}")
        end
      end

      it 'has max sector selection' do
        visit "/usuarios/#{@user_permission_requested.id}/permisos"
        sectors = Sector.all.sample(4)
        sectors.each do |sector|
          click_button 'Agregar sector'
          sleep 1
          find('select#remote_form_sector_selector + button').click
          find('a', text: "#{sector.name} - #{sector.establishment.name}").click
          sleep 1
          click_button 'Guardar'
          sleep 1
        end
        expect(page).to have_content('La cantidad de sectores seleccionados supera el máximo de 3')
      end

      it 'has active sector' do
        user = @user_build_from_pr.sample
        active_sector = user.user_sectors.active.first.sector
        visit "/usuarios/#{user.id}/permisos"
        within '#location_select_container' do
          expect(page).to have_selector('a', class: 'active',
                                             text: "#{active_sector.name} - #{active_sector.establishment.name}")
        end
      end

      it 'set permissions by role' do
        role = Role.all.sample
        visit "/usuarios/#{@user_build_without_role.id}/permisos"
        within '#location_select_container' do
          page.first('label', text: role.name).click
        end
        role.permissions.each do |permission|
          expect(page).to have_checked_field(
            "permission[permission_users_attributes][#{permission.id}][permission_id]", visible: false
          )
        end
      end
    end
  end
end

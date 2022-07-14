require 'rails_helper'

RSpec.feature 'Users', type: :feature, js: true do
  before(:all) do
    @permission_module = create(:permission_module, name: 'Usuarios')
    @read_users = create(:permission, name: 'read_users', permission_module: @permission_module)
    @answer_permission_request = create(:permission, name: 'answer_permission_request', permission_module: @permission_module)
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
        create(:permission_req_1)
        visit current_path
        within '#permission_requests' do
          expect(page).to have_selector('tr', count: 1)
          page.execute_script %Q{$('tr.info')[0].click()}
        end
        expect(page).to have_content('Solicitud de permisos en progreso')
        sleep 10
      end
    end
  end
end

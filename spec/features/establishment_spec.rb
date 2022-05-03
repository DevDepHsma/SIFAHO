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
          expect(page).to have_selector('.btn-detail', count: 1)
          page.execute_script %Q{$('a.btn-detail')[0].click()}
          sleep 1
        end
      end


    end
  end
end

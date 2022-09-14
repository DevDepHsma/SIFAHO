require 'rails_helper'

RSpec.feature "Reports::ExternalOrderProductReports", type: :feature do
  before(:all) do
    @permission_module = create(:permission_module, name: 'Reportes')
    
    @external_order_by_products = create(:permission, name: 'external_order_by_products', permission_module: @permission_module)
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
        visit '/'
      end

      it 'External order Products report' do
        expect(page.has_css?('#sidebar-wrapper')).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Reportes')).to be false
        end

        PermissionUser.create(user: @user, sector: @user.sector, permission: @external_order_by_products)
        visit current_path
        within '#sidebar-wrapper' do
          expect(page.has_link?('Reportes')).to be true
          click_link 'Reportes'
        end

        within '#sdropdown-menu-header' do
          expect(page.has_link?('Establecimientos')).to be true
        end

        expect(page).to have_content('Nuevo reporte de producto entregado por establecimientos')
        expect(page.has_button?('Generar')).to be true
      end
    end
  end
end

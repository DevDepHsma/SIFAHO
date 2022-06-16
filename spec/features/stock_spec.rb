require 'rails_helper'

RSpec.feature "Stocks", type: :feature do
  before(:all) do
    @permission_module = create(:permission_module, name: 'Stock')
    @read_stocks = create(:permission, name: 'read_stocks', permission_module: @permission_module)
    @read_archive_stocks = create(:permission, name: 'read_archive_stocks', permission_module: @permission_module)
    @create_archive_stocks = create(:permission, name: 'create_archive_stocks', permission_module: @permission_module)
    @return_archive_stocks = create(:permission, name: 'return_archive_stocks', permission_module: @permission_module)
    @read_lot_stocks = create(:permission, name: 'read_lot_stocks', permission_module: @permission_module)

    @pm_lots = create(:permission_module, name: 'Lotes')
    @read_lots = create(:permission, name: 'read_lots', permission_module: @pm_lots)
    # @create_lots = create(:permission, name: 'create_lots', permission_module: @pm_lots)
    # @update_lots = create(:permission, name: 'update_lots', permission_module: @pm_lots)
    # @destroy_lots = create(:permission, name: 'destroy_lots', permission_module: @pm_lots)
  end

  background do
    sign_in_as(@provider_user)
  end

  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe "Add permission:" do
      before(:each) do
        PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @read_stocks)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Stock')).to be true
          click_link 'Stock'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Stock')).to be true
        end
        expect(page).to have_selector('#stocks')

        within '#stocks' do
          expect(page).to have_selector('.btn-detail')
          page.execute_script %Q{$('a.btn-detail')[0].click()}
        end

        expect(page).to have_content('Viendo stock de')
        expect(page).not_to have_selector('#lots-tab')
        expect(page).to have_selector('#movements-tab')
        expect(page).to have_selector('#statistics-tab')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_link?('Imprimir')).to be true
        expect(page.has_link?('Ver Lotes')).to be false
        expect(page.has_link?('Ver Movimientos')).to be false
        expect(page).not_to have_selector('.btn-detail-lot')
        PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @read_lot_stocks)
        visit current_path
        expect(page).to have_selector('#lots-tab')
        PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @read_lots)
        visit current_path
        expect(page).to have_selector('.btn-detail-lot')
        # Lot detail
        # PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @read_lots)
        # Lot Movements
        # Lot stocks
      end
    end
  end
end
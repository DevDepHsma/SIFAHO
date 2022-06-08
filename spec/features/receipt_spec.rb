require 'rails_helper'

RSpec.feature "Receipts", type: :feature do
  before(:all) do
    @permission_module = create(:permission_module, name: 'Recibos')
    @read_receipts = create(:permission, name: 'read_receipts', permission_module: @permission_module)
    @create_receipts = create(:permission, name: 'create_receipts', permission_module: @permission_module)
    @update_receipts = create(:permission, name: 'update_receipts', permission_module: @permission_module)
    @destroy_receipts = create(:permission, name: 'destroy_receipts', permission_module: @permission_module)
    @rollback_receipts = create(:permission, name: 'rollback_receipts', permission_module: @permission_module)
    @receive_receipts = create(:permission, name: 'receive_receipts', permission_module: @permission_module)
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
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_receipts)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Stock')).to be true
          click_link 'Stock'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Recibos')).to be true
        end

        # within '#receipts' do
        #   expect(page).to have_selector('.btn-detail')
        #   page.execute_script %Q{$('a.btn-detail')[0].click()}
        # end
        # expect(page).to have_content('Viendo laboratorio')
        # expect(page.has_link?('Volver')).to be true
        # click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @create_receipts)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Cargar por recibo')).to be true
          click_link 'Cargar por recibo'
        end

        expect(page.has_css?('#effector-establishment')).to be true
        expect(page.has_css?('#provider-sector', visible: false)).to be true
        expect(page.has_css?('#receipt-cocoon-container')).to be true
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        select_sector(@farmacia_other_establishment.name, 'select#provider-sector', @other_establishment)

        prods = @products.sample(3)
        add_products_by_receipt(prods, request_quantity: true, lot_code: true, laboratory: true)
        click_button 'Guardar'

        expect(page).to have_content('Viendo recibo')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_link?('Imprimir')).to be true

        click_link 'Volver'

        within '#receipts' do
          expect(page).to have_selector('.btn-detail', count: 1)
        end
        PermissionUser.create(user: @user, sector: @user.sector, permission: @update_receipts)
        visit current_path
        sleep 5
        within '#receipts' do
          expect(page).to have_selector('.btn-edit', count: 1)
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando recibo')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_receipts)
        visit current_path
        within '#receipts' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %Q{$('td:contains("ABC Prueba")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar recibo')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#receipts' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end

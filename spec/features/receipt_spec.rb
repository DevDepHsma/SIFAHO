require 'rails_helper'

RSpec.feature 'Receipts', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recibos')
    @read_receipts = permission_module.permissions.find_by(name: 'read_receipts')
    @create_receipts = permission_module.permissions.find_by(name: 'create_receipts')
    @update_receipts = permission_module.permissions.find_by(name: 'update_receipts')
    @destroy_receipts = permission_module.permissions.find_by(name: 'destroy_receipts')
    @rollback_receipts = permission_module.permissions.find_by(name: 'rollback_receipts')
    @receive_receipts = permission_module.permissions.find_by(name: 'receive_receipts')
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
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_receipts)
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
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @create_receipts)
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
        select_sector(@depo_est_2.name, 'select#provider-sector', @depo_est_2.establishment)

        add_products(rand(1..3), request_quantity: true, lot_code: true, laboratory: true)
        click_button 'Guardar'

        expect(page).to have_content('Viendo recibo')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_link?('Imprimir')).to be true
        expect(page.has_button?('Recibir')).to be false

        click_link 'Volver'

        within '#receipts' do
          expect(page).to have_selector('.btn-detail', count: 1)
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @update_receipts)
        visit current_path
        within '#receipts' do
          expect(page).to have_selector('.btn-edit', count: 1)
          page.execute_script %{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando recibo')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Agregar producto'
        add_products(rand(1..2), request_quantity: true, lot_code: true, laboratory: true)
        click_button 'Guardar'

        expect(page).to have_content('Viendo recibo')
        expect(page.has_button?('Recibir')).to be false
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @receive_receipts)
        visit current_path
        expect(page.has_button?('Recibir')).to be true

        click_button 'Recibir'
        sleep 1
        expect(page).to have_content('Recibir remito')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_link?('Continuar')).to be true
        click_link 'Continuar'
        sleep 1

        expect(page.has_button?('Retornar')).to be false
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @rollback_receipts)
        visit current_path
        expect(page.has_button?('Retornar')).to be true
        click_button 'Retornar'
        sleep 1
        expect(page).to have_content('Retornar recibo')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_link?('Continuar')).to be true
        click_link 'Continuar'
        sleep 1
        click_link 'Volver'

        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @destroy_receipts)
        visit current_path
        within '#receipts' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %{$('td').first().closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar recibo')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#receipts' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end

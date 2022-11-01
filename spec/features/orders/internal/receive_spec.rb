require 'rails_helper'

RSpec.feature "Orders::Internal::Receives", type: :feature do
  before(:all) do
    permission_module_applicant = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Solicitud')
    permission_module_applicant.permissions.map { |permission|
      PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: permission)
    }
    permission_module_provider = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Proveedor')
    permission_module_provider.permissions.map { |permission|
      PermissionUser.create(user: @depo_applicant, sector: @depo_applicant.sector, permission: permission)
    }
  end

  background do
    sign_in @farm_applicant
  end

  describe 'Permissions::Receive', js: true do
    subject { page }

    it ':: READ :: success' do
      visit '/'
      expect(page.has_link?('Sectores')).to be true
      within '#sidebar-wrapper' do
        click_link 'Sectores'
      end
      click_link 'Solicitar'
      within '#order-form' do
        select_sector(@depo_applicant.sector.name, 'select#provider-sector')
      end
      expect(page).to have_content(@depo_applicant.sector.name)
      click_button 'Guardar y agregar productos'
      add_products(rand(1..3), request_quantity: true, observations: true)
      click_button 'Enviar'
      expect(page).to have_content('La solicitud se ha enviado correctamente.')
      expect(page).to have_content('Solicitud enviada')
      expect(page).to have_content('Productos')
      sign_out_as(@farm_applicant)
      sign_in_as(@depo_applicant)
      within '#sidebar-wrapper' do
        click_link 'Sectores'
      end
      within '#provider_orders' do
        expect(page).to have_selector('tr')
        expect(page).to have_selector('.btn-edit-product')
        expect(page).to have_selector('.btn-nullify')
        page.execute_script %Q{$('button.btn-nullify')[0].click()}
        sleep 1
      end
      expect(page).to have_content('Confirmar anulación de orden')
      expect(page.has_link?('Cancelar')).to be true
      expect(page.has_link?('Anular')).to be true
      click_link 'Cancelar'
      sleep 1
      within '#provider_orders' do
        page.execute_script %Q{$('a.btn-edit-product')[0].click()}
      end
      sleep 1
      fill_products_deliver_quantity
      expect(page.has_link?('Agregar producto')).to be true
      click_link 'Agregar producto'
      sleep 1
      add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
      click_button 'Enviar'
      sleep 1
      expect(page).to have_content('Enviando provisión de sector')
      expect(page).to have_content('Desea enviar la provisión?')
      click_link 'Enviar'
      sleep 1
      expect(page).to have_content('La provision se ha enviado correctamente.')
      expect(page).to have_content('Provision en camino')
      expect(page).to have_content('Productos')
      sign_out_as(@depo_applicant)
      sign_in_as(@farm_applicant)
      within '#sidebar-wrapper' do
        click_link 'Sectores'
      end
      within '#applicant_orders' do
        expect(page).to have_selector('tr')
        expect(page).to have_selector('.btn-detail')
        page.execute_script %Q{$('a.btn-detail')[0].click()}
      end
      expect(page.has_button?('Recibir')).to be true
      click_button 'Recibir'
      sleep 1
      expect(page).to have_content('Confirmar recibo de pedido de sector')
      expect(page.has_link?('Cancelar')).to be true
      expect(page.has_link?('Confirmar')).to be true
      click_link 'Confirmar'
      sleep 1
      expect(page).to have_content('La solicitud se ha recibido correctamente')
      expect(page).to have_content('Provision entregada')
    end
  end
end

require 'rails_helper'

RSpec.feature 'Orders::External::Receives', type: :feature do
  before(:all) do
    permission_module_applicant = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Externas Solicitud')
    permission_module_provider = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Externas Proveedor')
    permission_module_applicant.permissions.map do |permission|
      PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: permission)
    end
    permission_module_provider.permissions.map do |permission|
      PermissionUser.create(user: @depo_provider, sector: @depo_provider.active_sector, permission: permission)
    end
  end

  background do
    sign_in @farm_applicant
  end

  describe 'Permissions::Receive', js: true do
    subject { page }

    it ':: READ :: success' do
      visit '/'
      expect(page).to have_link('Establecimientos')
      within '#sidebar-wrapper' do
        click_link 'Establecimientos'
      end
      click_link 'Solicitar'
      sleep 1
      select_sector(@depo_provider.active_sector.name, 'select#effector-sector',
                    @depo_provider.active_sector.establishment)
      expect(page).to have_content(@depo_provider.active_sector.name)
      click_button 'Guardar y agregar productos'

      add_products(rand(1..3), request_quantity: true, observations: true)
      expect(page).to have_selector('input.product-code')
      expect(page).to have_button('Enviar')
      click_button 'Enviar'
      expect(page).to have_content('La solicitud se ha enviado correctamente.')
      expect(page).to have_content('Solicitud enviada')
      expect(page).to have_content('Productos')
      sign_out_as(@farm_applicant)
      sign_in_as(@depo_provider)
      within '#sidebar-wrapper' do
        click_link 'Establecimientos'
      end
      click_link 'Despachos'
      sleep 1
      within '#external_orders' do
        expect(page).to have_selector('tr')
        expect(page).to have_selector('.btn-edit-product')
        expect(page).to have_selector('.btn-nullify')
        page.execute_script %{$('button.btn-nullify')[0].click()}
        sleep 1
      end
      expect(page).to have_content('Confirmar anulación de orden')
      expect(page).to have_link('Cancelar')
      expect(page).to have_link('Anular')
      click_link 'Cancelar'
      sleep 1
      within '#external_orders' do
        page.execute_script %{$('a.btn-edit-product')[0].click()}
      end
      sleep 1
      fill_products_deliver_quantity
      expect(page).to have_link('Agregar producto')
      click_link 'Agregar producto'
      sleep 1
      add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
      expect(page).to have_button('Aceptar')
      click_button 'Aceptar'
      expect(page).to have_content('La provision se ha aceptado correctamente.')
      expect(page).to have_content('Proveedor aceptado')
      expect(page).to have_content('Productos')
      click_button 'Enviar provisión'
      sleep 1
      expect(page).to have_content('Confirmar envío de despacho')
      expect(page).to have_content('Desea enviar la provisión?')
      click_link 'Confirmar'
      sleep 1
      expect(page).to have_content('La provision se ha enviado correctamente.')
      expect(page).to have_content('Provision en camino')
      sign_out_as(@depo_provider)
      sign_in_as(@farm_applicant)
      within '#sidebar-wrapper' do
        click_link 'Establecimientos'
      end
      click_link 'Recibos'
      within '#external_orders' do
        expect(page).to have_selector('tr')
        expect(page).to have_selector('.btn-detail')
      end

      order = ExternalOrder.where(order_type: 'solicitud', status: 'provision_en_camino',
                                  applicant_sector_id: @farm_applicant.active_sector.id).first
      visit "/establecimientos/pedidos/recibos/#{order.id}"
      expect(page).to have_button('Recibir')
      click_button 'Recibir'
      sleep 1
      expect(page).to have_content('Confirmar recibo de pedido de establecimiento')
      expect(page).to have_link('Cancelar')
      expect(page).to have_link('Confirmar')
      click_link 'Confirmar'
      expect(page).to have_content('La solicitud se ha recibido correctamente')
      expect(page).to have_content('Provision entregada')
    end
  end
end

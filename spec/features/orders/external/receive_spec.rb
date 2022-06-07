require 'rails_helper'

RSpec.feature "Orders::External::Receives", type: :feature do
  before(:all) do
    [@read_external_order_applicant,
      @create_external_order_applicant,
      @update_external_order_applicant,
      @destroy_external_order_applicant,
      @send_external_order_applicant,
      @receive_external_order_applicant,
      @return_external_order_applicant].map { |permission|
      PermissionUser.create(user: @farmacia_hja, sector: @farmacia_hja.sector, permission: permission)
    }
    [@read_external_order_provider,
      @create_external_order_provider,
      @update_external_order_provider,
      @destroy_external_order_provider,
      @send_external_order_provider,
      @nullify_external_order_provider,
      @return_external_order_provider,
      @accept_external_order_provider].map { |permission|
      PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: permission)
    }
  end

  background do
    sign_in_as(@farmacia_hja)
  end

  describe 'Permissions::Receive', js: true do
    subject { page }

    it ':: READ :: success' do
      expect(page.has_link?('Establecimientos')).to be true
      within '#sidebar-wrapper' do
        click_link 'Establecimientos'
      end
      click_link 'Solicitar'
      sleep 1
      select_sector(@deposito.name, 'select#effector-sector', @establishment)
      expect(page).to have_content(@deposito.name)
      click_button 'Guardar y agregar productos'

      applicant_products = @products.sample(3)
      add_products(applicant_products, request_quantity: true, observations: true)
      expect(page).to have_selector('input.product-code', count: 3)
      expect(page.has_button?('Enviar')).to be true
      click_button 'Enviar'
      expect(page).to have_content('La solicitud se ha enviado correctamente.')
      expect(page).to have_content('Solicitud enviada')
      expect(page).to have_content('Productos 3')
      sign_out_as(@farmacia_hja)
      sign_in_as(@provider_user)
      within '#sidebar-wrapper' do
        click_link 'Establecimientos'
      end
      click_link 'Despachos'
      sleep 1
      within '#external_orders' do
        expect(page).to have_selector('tr', count: 1)
        expect(page).to have_selector('.btn-edit-product', count: 1)
        expect(page).to have_selector('.btn-nullify', count: 1)
        page.execute_script %Q{$('button.btn-nullify')[0].click()}
        sleep 1
      end
      expect(page).to have_content('Confirmar anulación de orden')
      expect(page.has_link?('Cancelar')).to be true
      expect(page.has_link?('Anular')).to be true
      click_link 'Cancelar'
      sleep 1
      within '#external_orders' do
        page.execute_script %Q{$('a.btn-edit-product')[0].click()}
      end
      sleep 1
      fill_products_deliver_quantity(applicant_products)
      expect(page.has_link?('Agregar producto')).to be true
      click_link 'Agregar producto'
      sleep 1
      provider_prods = (@products - applicant_products).sample(3)
      add_products(provider_prods, request_quantity: true, observations: true, select_lot_stock: true)
      expect(page.has_button?('Aceptar')).to be true
      click_button 'Aceptar'
      expect(page).to have_content('La provision se ha aceptado correctamente.')
      expect(page).to have_content('Proveedor aceptado')
      expect(page).to have_content('Productos 6')
      click_button 'Enviar provisión'
      sleep 1
      expect(page).to have_content('Confirmar envío de despacho')
      expect(page).to have_content('Desea enviar la provisión?')
      click_link 'Confirmar'
      sleep 1
      expect(page).to have_content('La provision se ha enviado correctamente.')
      expect(page).to have_content('Provision en camino')
      sign_out_as(@provider_user)
      sign_in_as(@farmacia_hja)
      within '#sidebar-wrapper' do
        click_link 'Establecimientos'
      end
      click_link 'Recibos'
      within '#applicant_orders' do
        expect(page).to have_selector('tr', count: 1)
        expect(page).to have_selector('.btn-detail', count: 1)
        page.execute_script %Q{$('a.btn-detail')[0].click()}
      end
      expect(page.has_button?('Recibir')).to be true
      click_button 'Recibir'
      sleep 1
      expect(page).to have_content('Confirmar recibo de pedido de establecimiento')
      expect(page).to have_content('El pedido contiene 6 productos diferentes.')
      expect(page.has_link?('Cancelar')).to be true
      expect(page.has_link?('Confirmar')).to be true
      click_link 'Confirmar'
      sleep 1
      expect(page).to have_content('La solicitud se ha recibido correctamente')
      expect(page).to have_content('Provision entregada')
    end
  end
end

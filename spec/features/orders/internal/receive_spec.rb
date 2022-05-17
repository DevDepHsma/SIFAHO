require 'rails_helper'

RSpec.feature "Orders::Internal::Receives", type: :feature do
  before(:all) do
    [@read_internal_order_applicant, @create_internal_order_applicant, @update_internal_order_applicant, 
     @destroy_internal_order_applicant, @send_internal_order_applicant, @receive_internal_order_applicant, 
     @return_internal_order_applicant].map { |permission|
      PermissionUser.create(user: @applicant_user, sector: @applicant_user.sector, permission: permission)
    }
    [@read_internal_order_provider, @create_internal_order_provider, @update_internal_order_provider,
     @destroy_internal_order_provider, @send_internal_order_provider, @nullify_internal_order_provider,
     @return_internal_order_provider].map { |permission|
      PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: permission)
    }
  end

  background do
    sign_in_as(@applicant_user)
  end

  describe 'Permissions::Receive', js: true do
    subject { page }

    it ':: READ :: success' do
      expect(page.has_link?('Sectores')).to be true
      within '#sidebar-wrapper' do
        click_link 'Sectores'
      end
      click_link 'Solicitar'
      within '#order-form' do
        select_sector(@deposito.name, 'select#provider-sector')
      end
      expect(page).to have_content(@deposito.name)
      click_button 'Guardar y agregar productos'
      prods = @products.sample(3)
      @products = @products - prods
      add_products(prods, request_quantity: true, observations: true)
      click_button 'Enviar'
      expect(page).to have_content('La solicitud se ha enviado correctamente.')
      expect(page).to have_content('Solicitud enviada')
      expect(page).to have_content('Productos 3')
      sign_out_as(@applicant_user)
      sign_in_as(@provider_user)
      within '#sidebar-wrapper' do
        click_link 'Sectores'
      end
      within '#provider_orders' do
        expect(page).to have_selector('tr', count: 1)
        expect(page).to have_selector('.btn-edit-product', count: 1)
        page.execute_script %Q{$('a.btn-edit-product')[0].click()}
      end
      sleep 1
      fill_products_deliver_quantity(prods)
      expect(page.has_link?('Agregar producto')).to be true
      click_link 'Agregar producto'
      sleep 1
      prov_prods = @products.sample(3)
      add_products(prov_prods, request_quantity: true, observations: true, select_lot_stock: true)
      click_button 'Enviar'
      sleep 1
      expect(page).to have_content('Enviando provisión de sector')
      expect(page).to have_content('Desea enviar la provisión?')
      click_link 'Enviar'
      sleep 1
      expect(page).to have_content('La provision se ha enviado correctamente.')
      expect(page).to have_content('Provision en camino')
      expect(page).to have_content('Productos 6')
      sign_out_as(@provider_user)
      sign_in_as(@applicant_user)
      within '#sidebar-wrapper' do
        click_link 'Sectores'
      end
      within '#applicant_orders' do
        expect(page).to have_selector('tr', count: 1)
        expect(page).to have_selector('.btn-detail', count: 1)
        page.execute_script %Q{$('a.btn-detail')[0].click()}
      end
      expect(page.has_button?('Recibir')).to be true
      click_button 'Recibir'
      sleep 1
      expect(page).to have_content('Confirmar recibo de pedido de sector')
      expect(page).to have_content('Contiene 6 productos diferentes.')
      expect(page.has_link?('Cancelar')).to be true
      expect(page.has_link?('Confirmar')).to be true
      click_link 'Confirmar'
      sleep 1
      expect(page).to have_content('La solicitud se ha recibido correctamente')
      expect(page).to have_content('Provision entregada')
    end
  end
end

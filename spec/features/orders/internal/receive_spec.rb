require 'rails_helper'

RSpec.feature "Orders::Internal::Receives", type: :feature do
  before(:all) do
    @establishment = create(:establishment_1)
    @farmacia = create(:sector_1, establishment: @establishment)
    @deposito = create(:sector_4, establishment: @establishment)
    @applicant_user = create(:user_1, sector: @farmacia)
    @provider_user = create(:user_2, sector: @deposito)

    @pm_ois = create(:permission_module, name: 'Ordenes Internas Solicitud')
    @read_internal_order_applicant = create(:permission, name: 'read_internal_order_applicant', permission_module: @pm_ois)
    @create_internal_order_applicant = create(:permission, name: 'create_internal_order_applicant', permission_module: @pm_ois)
    @update_internal_order_applicant = create(:permission, name: 'update_internal_order_applicant', permission_module: @pm_ois)
    @destroy_internal_order_applicant = create(:permission, name: 'destroy_internal_order_applicant', permission_module: @pm_ois)
    @send_internal_order_applicant = create(:permission, name: 'send_internal_order_applicant', permission_module: @pm_ois)
    @receive_internal_order_applicant = create(:permission, name: 'receive_internal_order_applicant', permission_module: @pm_ois)
    @return_internal_order_applicant = create(:permission, name: 'return_internal_order_applicant', permission_module: @pm_ois)
    [@read_internal_order_applicant, @create_internal_order_applicant, @update_internal_order_applicant, 
     @destroy_internal_order_applicant, @send_internal_order_applicant, @receive_internal_order_applicant, 
     @return_internal_order_applicant].map { |permission|
      PermissionUser.create(user: @applicant_user, sector: @applicant_user.sector, permission: permission)
     }

    @pm_oip = create(:permission_module, name: 'Ordenes Internas Proveedor')
    @read_internal_order_provider = create(:permission, name: 'read_internal_order_provider', permission_module: @pm_oip)
    @create_internal_order_provider = create(:permission, name: 'create_internal_order_provider', permission_module: @pm_oip)
    @update_internal_order_provider = create(:permission, name: 'update_internal_order_provider', permission_module: @pm_oip)
    @destroy_internal_order_provider = create(:permission, name: 'destroy_internal_order_provider', permission_module: @pm_oip)
    @send_internal_order_provider = create(:permission, name: 'send_internal_order_provider', permission_module: @pm_oip)
    @nullify_internal_order_provider = create(:permission, name: 'nullify_internal_order_provider', permission_module: @pm_oip)
    @return_internal_order_provider = create(:permission, name: 'return_internal_order_provider', permission_module: @pm_oip)
    [@read_internal_order_provider, @create_internal_order_provider, @update_internal_order_provider,
     @destroy_internal_order_provider, @send_internal_order_provider, @nullify_internal_order_provider,
     @return_internal_order_provider].map { |permission|
      PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: permission)
     }

    @products = get_products
    @unity = create(:unidad_unity)
    @area = create(:medication_area)
    @lab = create(:abbott_laboratory)
    @provenance = create(:province_lot_provenance)
    @products.each_with_index do |product, index|
      prod = create(:product, name: product[0], code: product[1], area: @area, unity: @unity)
      lot = create(:lot, laboratory: @lab, product: prod, code: "BB-#{index}", expiry_date: Date.today + 15.month, provenance: @provenance)
      stock = create(:stock, product: prod, sector: @deposito)
      LotStock.create(quantity: rand(1500..5000), lot: lot, stock: stock)
    end
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
      click_button 'Enviar'
      sleep 1
      expect(page).to have_content('Enviando provisión de sector')
      expect(page).to have_content('Desea enviar la provisión?')
      click_link 'Enviar'
      sleep 1
      expect(page).to have_content('La provision se ha enviado correctamente.')
      expect(page).to have_content('Provision en camino')
      expect(page).to have_content('Productos 3')
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
      expect(page).to have_content('Contiene 3 productos diferentes.')
      expect(page.has_link?('Cancelar')).to be true
      expect(page.has_link?('Confirmar')).to be true
      click_link 'Confirmar'
      sleep 1
      expect(page).to have_content('La solicitud se ha recibido correctamente')
      expect(page).to have_content('Provision entregada')
    end
  end
end

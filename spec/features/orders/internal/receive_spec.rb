require 'rails_helper'

RSpec.feature 'Orders::Internal::Receives', type: :feature do
  before(:all) do
    permission_module_applicant = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Solicitud')
    permission_module_applicant.permissions.map do |permission|
      PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: permission)
    end
    permission_module_provider = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Proveedor')
    permission_module_provider.permissions.map do |permission|
      PermissionUser.create(user: @depo_applicant, sector: @depo_applicant.active_sector, permission: permission)
    end
  end

  background do
    sign_in @farm_applicant
  end

  describe 'Permissions::Receive', js: true do
    subject { page }
    describe 'actions applicant' do
      it 'new order' do
        visit '/sectores'
        click_link 'Solicitar'
        within '#order-form' do
          select_sector(@depo_applicant.active_sector.name, 'select#provider-sector')
        end
        expect(page).to have_content(@depo_applicant.active_sector.name)
        expect(page).to have_button('Guardar y agregar productos')
        click_button 'Guardar y agregar productos'
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
        expect(page).to have_content('La solicitud se ha enviado correctamente.')
        expect(page).to have_content('Solicitud enviada')
        expect(page).to have_content('Productos')
        sign_out_as(@farm_applicant)
      end

      it 'nullify' do
        sign_in @depo_applicant
        visit '/sectores'
        click_link 'Entregas'
        within '#internal_orders' do
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
      end

      it 'edit' do
        sign_in @depo_applicant
        visit '/sectores'
        click_link 'Entregas'
        within '#internal_orders' do
          expect(page).to have_selector('tr')
          expect(page).to have_selector('.btn-edit-product')
          expect(page).to have_selector('.btn-nullify')
          page.execute_script %{$('a.btn-edit-product')[0].click()}
          sleep 1
        end
        sleep 1
        fill_products_deliver_quantity
        expect(page).to have_link('Agregar producto')
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
      end
    end

    describe 'actions provider' do
      it 'receive order' do
        visit '/sectores'
        click_link 'Recibos'
        order_receive = InternalOrder.where(status: 'provision_en_camino',
                                            applicant_sector_id: @farm_applicant.active_sector.id.to_s).first
        within '#internal_orders' do
          expect(page).to have_selector('tr')
          expect(page).to have_selector('.btn-detail')
          visit "/sectores/pedidos/recibos/#{order_receive.id}"
        end
        sleep 1
        expect(page).to have_button('Recibir')
        click_button 'Recibir'
        sleep 1
        expect(page).to have_content('Confirmar recibo de pedido de sector')
        expect(page).to have_link('Cancelar')
        expect(page).to have_link('Confirmar')
        click_link 'Confirmar'
        sleep 1
        expect(page).to have_content('La provision se ha recibido correctamente')
        expect(page).to have_content('Provision entregada')
      end
    end
  end
end

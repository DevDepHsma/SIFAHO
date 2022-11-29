require 'rails_helper'

RSpec.feature 'Orders::Internal::Applicants', type: :feature do
  before(:all) do
    perimssion_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Solicitud')
    @read_internal_order_applicant = perimssion_module.permissions.find_by(name: 'read_internal_order_applicant')
    @create_internal_order_applicant = perimssion_module.permissions.find_by(name: 'create_internal_order_applicant')
    @update_internal_order_applicant = perimssion_module.permissions.find_by(name: 'update_internal_order_applicant')
    @send_internal_order_applicant = perimssion_module.permissions.find_by(name: 'send_internal_order_applicant')
    @return_internal_order_applicant = perimssion_module.permissions.find_by(name: 'return_internal_order_applicant')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @create_internal_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @read_internal_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @update_internal_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @send_internal_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @return_internal_order_applicant)
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    describe 'Permission:' do
      before(:each) do
        visit '/sectores'
      end
      it 'list' do
        click_link 'Recibos'
        expect(page).to have_css('#table_results')
      end

      it 'show' do
        click_link 'Recibos'
        order = InternalOrder.where(status: 'solicitud_auditoria', applicant_sector_id: @farm_applicant.active_sector_id).first
        visit "/sectores/pedidos/recibos/#{order.id}"
        expect(page).to have_content('Solicitante')
        expect(page).to have_content('Proveedor')
        expect(page).to have_content('Solicitado')
        expect(page).to have_content('Código')
        expect(page).to have_content('Observaciones')
        expect(page).to have_link('Volver')
        expect(page).to have_link('Editar orden')
        expect(page).to have_link('Editar productos')
        expect(page).to have_link('Enviar solicitud')
      end

      it 'create' do
        within '#dropdown-menu-header' do
          expect(page).to have_link('Solicitar')
          click_link 'Solicitar'
        end
        expect(page).to have_content('Nueva solicitud de sector')
        expect(page).to have_content('Últimas solicitudes de sectores')
        expect(page).to have_select('internal_order[provider_sector_id]', visible: false)
        expect(page).to have_field('internal_order[observation]', type: 'textarea', visible: false)
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar y agregar productos')
      end

      it 'edit' do
        within '#dropdown-menu-header' do
          expect(page).to have_link('Solicitar')
          click_link 'Solicitar'
        end
        within '#order-form' do
          select_sector(@depo_applicant.active_sector.name, 'select#provider-sector')
        end
        expect(page).to have_content(@depo_applicant.active_sector.name)
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('Editando productos de solicitud de sector código')
        expect(page).to have_content('Solicitante')
        expect(page).to have_content(@farm_applicant.active_sector.name)
        expect(page).to have_content('Proveedor')
        expect(page).to have_content(@depo_applicant.active_sector.name)
        expect(page).to have_content('Código')
        expect(page).to have_content('Producto')
        expect(page).to have_content('Unidad')
        expect(page).to have_content('Tu stock')
        expect(page).to have_content('Solicitar')
        expect(page).to have_content('Solicitado')
        expect(page).to have_content('Tu observación')
        expect(page).to have_link('Volver')
        expect(page).to have_button('Enviar')
      end
    end

    describe 'Form' do
      before(:each) do
        visit 'sectores/pedidos/recibos'
      end
      it 'create' do
        click_link 'Solicitar'
        within '#order-form' do
          select_sector(@depo_est_1.name, 'select#provider-sector')
        end
        fill_in 'internal_order[observation]', with: 'Lorem ipsum'
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La solicitud se ha creado y se encuentra en auditoria.')
      end
      it 'charge products' do
        click_link 'Solicitar'
        within '#order-form' do
          select_sector(@depo_est_1.name, 'select#provider-sector')
        end
        fill_in 'internal_order[observation]', with: 'Lorem ipsum'
        click_button 'Guardar y agregar productos'
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
        expect(page).to have_content('La solicitud se ha enviado correctamente')
      end

      it 'edit' do
        within '#internal_orders' do
          expect(page).to have_selector('tr')
          expect(page).to have_selector('.btn-edit')
          page.find('.btn-edit',match: :first).click
        end
        fill_in 'internal_order_observation', with: 'observación editada'
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La solicitud se ha modificado correctamente')
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
        expect(page).to have_content('La solicitud se ha enviado correctamente')
        click_button 'Retornar'
        expect(page).to have_content('Retornar a solicitud auditoria')
        expect(page).to have_content('Seguro que desea retornar la solicitud actual a solicitud auditoria?')
        expect(page).to have_content('De esta manera podrá seguir agregando o quitando productos del pedido.')
        click_link 'Confirmar'
        click_link 'Editar productos'
        page.all('.btn-delete-confirm').each do |product|
          product.click
          expect(page).to have_content('Eliminar producto')
          sleep 1
          click_link 'Confirmar'
          sleep 1
        end
        click_link 'Agregar producto'
        sleep 1
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
      end
    end
  end
end

require 'rails_helper'

RSpec.feature 'Orders::External::Providers', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Externas Proveedor')
    @read_external_order_provider = permission_module.permissions.find_by(name: 'read_external_order_provider')
    @create_external_order_provider = permission_module.permissions.find_by(name: 'create_external_order_provider')
    @update_external_order_provider = permission_module.permissions.find_by(name: 'update_external_order_provider')
    @accept_external_order_provider = permission_module.permissions.find_by(name: 'accept_external_order_provider')
    @send_external_order_provider = permission_module.permissions.find_by(name: 'send_external_order_provider')
    @return_external_order_provider = permission_module.permissions.find_by(name: 'return_external_order_provider')
    @destroy_external_order_provider = permission_module.permissions.find_by(name: 'destroy_external_order_provider')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @update_external_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @read_external_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @create_external_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @send_external_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @return_external_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @destroy_external_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @accept_external_order_provider)
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    describe 'Permission:' do
      it 'List' do
        visit '/'
        expect(page).to have_css('#sidebar-wrapper', visible: false)
        within '#sidebar-wrapper' do
          expect(page).to have_link('Establecimientos')
          click_link 'Establecimientos'
        end
      end

      it 'Show' do
        visit '/establecimientos/pedidos/despachos'
        within '#external_orders' do
          expect(page).to have_css('.btn-detail')
        end
        external_order = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(order_type: 'provision').sample
        visit "/establecimientos/pedidos/despachos/#{external_order.id}"
        sleep 1
        expect(page).to have_content("Viendo provision #{external_order.remit_code}")
        expect(page).to have_content('Solicitante')
        expect(page).to have_content(external_order.applicant_sector.name)
        expect(page).to have_content('Proveedor')
        expect(page).to have_content(external_order.provider_sector.name)
        expect(page).to have_content('Solicitado')
        expect(page).to have_content(external_order.requested_date.strftime('%d/%m/%Y'))
        expect(page).to have_content('Código')
        expect(page).to have_content('Observaciones')
        within '.card-footer' do
          expect(page).to have_link('Volver')
          expect(page).to have_link('Imprimir')
        end
      end

      it 'Create: form and fields' do
        sector = Sector.where.not(establishment_id: @farm_applicant.active_sector.establishment.id).sample
        establishment = sector.establishment
        visit '/establecimientos'
        within '#dropdown-menu-header' do
          expect(page).to have_link('Despachar')
          click_link 'Despachar'
        end
        expect(page).to have_content('Nueva provision de establecimiento')
        expect(page).to have_content('Establecimiento solicitante')
        expect(page).to have_content('Sector solicitante')
        expect(page).to have_content("#{@farm_applicant.active_sector.name} #{@farm_applicant.active_sector.establishment.name}")
        expect(page).to have_content('Proveedor')
        expect(page).to have_content('Últimos despachos de establecimientos')
        expect(page).to have_selector('#last-requests') # Verify table last-request present
        within '#new_external_order' do
          expect(page).to have_field('external_order[applicant_establishment_id]')
          expect(page).to have_field('external_order[provider_observation]')
        end
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('Por favor revise los campos en el formulario:')
        expect(page).to have_content('Sector solicitante no puede estar en blanco')
        within '#new_external_order' do
          fill_in 'external_order[applicant_establishment_id]',	with: establishment.name
        end
        expect(page).to have_selector('.ui-menu-item div')
        page.all('.ui-menu-item div').first.click
        page.find('button[data-id="effector-sector"]').click
        sleep 1
        input_sector = page.all('.bs-searchbox input').first
        input_sector.fill_in with: sector.name
        page.first('.inner.show ul li a').click
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar y agregar productos')
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La provisión se ha creado y se encuentra en auditoria.')
        sleep 1
        expect(page).to have_content('Editando provision de establecimiento código')
        expect(page).to have_content('Solicitante')
        expect(page).to have_content(@farm_applicant.active_sector.name)
        expect(page).to have_content('Proveedor')
        expect(page).to have_content('Código')
        expect(page).to have_content('Producto')
        expect(page).to have_content('Unidad')
        expect(page).to have_content('Tu stock')
        expect(page).to have_content('Tu observación')
        expect(page).to have_content('Editar')
        click_button 'Aceptar'
        within '#send-unsaved-confirmation' do
          sleep 1
          expect(page).to have_content('Enviando solicitud de establecimiento')
          expect(page).to have_content('Hay productos que no han sido guardados aún')
          expect(page).to have_button('Continuar edición')
          expect(page).to have_link('Continuar de todos modos')
          click_button 'Continuar edición'
        end
        add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
        click_button 'Aceptar'
        expect(page).to have_content('La provision se ha aceptado correctamente.')
        expect(page).to have_button('Enviar provisión')
        click_button 'Enviar provisión'
        sleep 1
        within '#send-confirm' do
          expect(page).to have_content('Confirmar envío de despacho')
          expect(page).to have_content('Una vez enviada la orden, no se podrán retornar los productos a stock.')
          expect(page).to have_content('Desea enviar la provisión?')
          expect(page).to have_link('Confirmar')
          expect(page).to have_link('Cancelar')
          click_link 'Confirmar'
        end
        expect(page).to have_content('La provision se ha enviado correctamente.')
      end

      it 'Edit: form and fields' do
        sector = Sector.where.not(establishment_id: @farm_applicant.active_sector.establishment.id).sample
        establishment = sector.establishment
        external_order = ExternalOrder.by_provider(@farm_applicant.active_sector.id).where(order_type: 'provision',
                                                                                           status: 'proveedor_auditoria').sample
        visit "/establecimientos/pedidos/despachos/#{external_order.id}/editar"
        expect(page).to have_content('Establecimiento solicitante')
        expect(page).to have_content('Sector solicitante')
        expect(page).to have_content("#{@farm_applicant.active_sector.name} #{@farm_applicant.active_sector.establishment.name}")
        expect(page).to have_content('Proveedor')
        expect(page).to have_content('Últimos despachos de establecimientos')
        expect(page).to have_selector('#last-requests') # Verify table last-request present
        within "#edit_external_order_#{external_order.id}" do
          expect(page).to have_field('Establecimiento solicitante')
          expect(page).to have_selector('select[name="external_order[applicant_sector_id]"]', visible: false)
          expect(page).to have_field('Observaciones')
        end
        fill_in 'Establecimiento solicitante', with: establishment.name
        expect(page).to have_selector('.ui-menu-item div')
        page.all('.ui-menu-item div').first.click
        page.find('button[data-id="effector-sector"]').click
        sleep 1
        input_sector = page.all('.bs-searchbox input').first
        input_sector.fill_in with: sector.name
        page.first('.inner.show ul li a').click
        click_button 'Guardar y agregar productos'
        sleep 1
        expect(page).to have_content('La provisión se ha auditado y se encuentra en auditoria.')
        add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
        click_button 'Aceptar'
        expect(page).to have_content('La provision se ha aceptado correctamente.')
        expect(page).to have_button('Enviar provisión')
        click_button 'Enviar provisión'
        sleep 1
        within '#send-confirm' do
          expect(page).to have_content('Confirmar envío de despacho')
          expect(page).to have_content('Una vez enviada la orden, no se podrán retornar los productos a stock.')
          expect(page).to have_content('Desea enviar la provisión?')
          expect(page).to have_link('Confirmar')
          expect(page).to have_link('Cancelar')
          click_link 'Confirmar'
        end
        expect(page).to have_content('La provision se ha enviado correctamente.')
      end

      it 'Templates' do
        visit '/establecimientos/pedidos/plantillas'
        expect(page).to have_content('Plantillas de despacho')
        expect(page).not_to have_content('Plantillas de solicitud')
        expect(page).to have_selector('#btn-provider-template')
        find('#btn-provider-template').click
        expect(page).to have_content('Agregar plantilla de provision a establecimiento')
        expect(page).to have_selector('#new_external_order_template')

        fill_order_template(
          form_id: '#new_external_order_template',
          template_name_input: 'external_order_template_name',
          template_name: 'Template Test',
          establishment_input: 'provider-establishment',
          sector_input: 'provider-sector',
          sector: @depo_provider.active_sector,
          products_size: 3
        )
        expect(page).to have_button('Guardar')
        click_button 'Guardar'
        expect(page).to have_content('Viendo plantilla de provision')
        expect(page).to have_selector('.delete-item')
        expect(page).to have_link('Volver')
        expect(page).to have_link('Imprimir')
        expect(page).to have_link('Editar')
        expect(page).to have_link('Crear despacho')
        click_link 'Editar'
        expect(page).to have_content('Editar plantilla de provision a establecimiento')
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
        click_link 'Volver'
        expect(page).to have_content('Template Test')
      end
    end
  end
end

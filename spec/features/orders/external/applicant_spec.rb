require 'rails_helper'

#  Test information

#  Testing modules:
#  Access permissions: List / Show /Create / Edit
#  Present fields on create
#  Present fields and values on edit
#  Save order
#  Validations on empty form
#
#

RSpec.feature 'Orders::External::Applicants', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Externas Solicitud')
    @read_external_order_applicant = permission_module.permissions.find_by(name: 'read_external_order_applicant')
    @create_external_order_applicant = permission_module.permissions.find_by(name: 'create_external_order_applicant')
    @update_external_order_applicant = permission_module.permissions.find_by(name: 'update_external_order_applicant')
    @send_external_order_applicant = permission_module.permissions.find_by(name: 'send_external_order_applicant')
    @return_external_order_applicant = permission_module.permissions.find_by(name: 'return_external_order_applicant')
    @destroy_external_order_applicant = permission_module.permissions.find_by(name: 'destroy_external_order_applicant')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @update_external_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @read_external_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @create_external_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @send_external_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @return_external_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @destroy_external_order_applicant)
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
        visit '/establecimientos/pedidos/recibos'
        within '#external_orders' do
          expect(page).to have_css('.btn-detail')
        end
        external_order = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(order_type: 'solicitud').sample
        visit "/establecimientos/pedidos/recibos/#{external_order.id}"
        sleep 1
        expect(page).to have_content("Viendo solicitud #{external_order.remit_code}")
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
          expect(page).to have_link('Editar productos')
          expect(page).to have_link('Enviar solicitud')
        end
      end

      it 'Create: form and fields' do
        sector = Sector.where.not(establishment_id: @farm_applicant.active_sector.establishment.id).sample
        establishment = sector.establishment
        visit '/establecimientos'
        within '#dropdown-menu-header' do
          expect(page).to have_link('Solicitar')
          click_link 'Solicitar'
        end
        expect(page).to have_content('Nueva solicitud de establecimiento')
        expect(page).to have_content('Solicitante')
        expect(page).to have_content("#{@farm_applicant.active_sector.name} #{@farm_applicant.active_sector.establishment.name}")
        expect(page).to have_content('Proveedor')
        expect(page).to have_content('Últimas solicitudes de establecimientos')
        expect(page).to have_selector('#last-requests') # Verify table last-request present
        within '#new_external_order' do
          expect(page).to have_field('external_order[applicant_observation]')
          expect(page).to have_field('external_order[provider_establishment_id]', type: 'text')
        end
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('Por favor revise los campos en el formulario:')
        expect(page).to have_content('Sector proveedor no puede estar en blanco')
        within '#new_external_order' do
          fill_in 'external_order[provider_establishment_id]',	with: establishment.name
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
        expect(page).to have_content('La solicitud de abastecimiento se ha creado y se encuentra en auditoría.')
        sleep 1
        expect(page).to have_content('Editando solicitud de establecimiento código')
        expect(page).to have_content('Solicitante')
        expect(page).to have_content(@farm_applicant.active_sector.name)
        expect(page).to have_content('Proveedor')
        expect(page).to have_content('Código')
        expect(page).to have_content('Producto')
        expect(page).to have_content('Unidad')
        expect(page).to have_content('Tu stock')
        expect(page).to have_content('Solicitar')
        expect(page).to have_content('Tu observación')
        click_button 'Enviar'
        expect(page).to have_content('Debe asignar almenos 1 producto.')  
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
        expect(page).to have_content('La solicitud se ha enviado correctamente')
      end

      it 'Edit: form and fields' do
        sector = Sector.where.not(establishment_id: @farm_applicant.active_sector.establishment.id).sample
        establishment = sector.establishment
        visit '/establecimientos/pedidos/recibos'
        within '#external_orders' do
          expect(page).to have_css('.btn-edit')
        end
        external_order = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(order_type: 'solicitud',
                                                                                            status: 'solicitud_auditoria').sample
        visit "/establecimientos/pedidos/recibos/#{external_order.id}/editar"
        sleep 1
        expect(page).to have_content('Editando solicitud de establecimiento código')
        expect(page).to have_link('Volver')
        expect(page).to have_link('Editar productos')
        expect(page).to have_link('Editar productos')
        expect(page).to have_button('Guardar y agregar productos')
        within "#edit_external_order_#{external_order.id}" do
          expect(page).to have_field('external_order[applicant_observation]')
          expect(page).to have_field('external_order[provider_establishment_id]', type: 'text')
          fill_in 'external_order[applicant_observation]',	with: 'observation editin'
          fill_in 'external_order[provider_establishment_id]',	with: establishment.name
        end
        expect(page).to have_selector('.ui-menu-item div')
        page.all('.ui-menu-item div').first.click
        page.find('button[data-id="effector-sector"]').click
        sleep 1
        input_sector = page.all('.bs-searchbox input').first
        input_sector.fill_in with: sector.name
        page.first('.inner.show ul li a').click
        click_button 'Guardar y agregar productos'
        expect(page).to have_content("Editando solicitud de establecimiento código #{external_order.remit_code}")
        expect(page).to have_link('Volver')
        expect(page).to have_button('Enviar')
        sleep 1
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
        expect(page).to have_content('La solicitud se ha enviado correctamente')
        expect(page).to have_button('Retornar')
        click_button 'Retornar'
        sleep 1
        expect(page).to have_content('Retornar a solicitud auditoria')
        expect(page).to have_link('Cancelar')
        expect(page).to have_link('Confirmar')
        click_link 'Confirmar'
        expect(page).to have_content('Solicitud auditoria')
      end

      it 'Templates' do
        visit '/establecimientos/pedidos/plantillas'
        expect(page).to have_content('Plantillas de solicitud')
        expect(page).not_to have_content('Plantillas de despacho')
        expect(page).to have_selector('#btn-applicant-template')
        find('#btn-applicant-template').click
        expect(page).to have_content('Agregar plantilla de solicitud a establecimiento')
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
        expect(page).to have_content('Viendo plantilla de solicitud')
        expect(page).to have_selector('.delete-item')
        expect(page).to have_link('Volver')
        expect(page).to have_link('Imprimir')
        expect(page).to have_link('Editar')
        expect(page).to have_link('Crear solicitud')
        click_link 'Editar'
        expect(page).to have_content('Editar plantilla de solicitud a establecimiento')
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
        click_link 'Volver'
        expect(page).to have_content('Template Test')
      end
    end
  end
end

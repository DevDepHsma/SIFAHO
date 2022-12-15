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
      it 'list' do
        visit '/sectores'
        click_link 'Recibos'
        expect(page).to have_css('#table_results')
      end

      it 'show' do
        order = InternalOrder.where(status: 'solicitud_auditoria',
                                    applicant_sector_id: @farm_applicant.active_sector.id).first
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

      it 'create and charge products:form and fields' do
        visit '/sectores/pedidos/recibos/nuevo'
        within '#dropdown-menu-header' do
          expect(page).to have_link('Solicitar')
        end
        expect(page).to have_content('Nueva solicitud de sector')
        expect(page).to have_content('Últimas solicitudes de sectores')
        expect(page).to have_select('internal_order[provider_sector_id]', visible: false)
        expect(page).to have_field('internal_order[observation]', type: 'textarea', visible: false)
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar y agregar productos')
        within '#order-form' do
          select_sector(@depo_est_1.name, 'select#provider-sector')
        end
        fill_in 'internal_order[observation]', with: 'Lorem ipsum'
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La solicitud se ha creado y se encuentra en auditoria.')
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
        expect(page).to have_content('La solicitud se ha enviado correctamente')
      end

      it 'Edit and charge products: form and fields' do
        order = InternalOrder.where(order_type: 'solicitud', status: 'solicitud_auditoria').sample
        visit "sectores/pedidos/recibos/#{order.id}/editar"
        expect(page).to have_content("Editando solicitud de sector código #{order.remit_code}")
        expect(page).to have_select('internal_order[provider_sector_id]', visible: false)
        expect(page).to have_field('internal_order[observation]', type: 'textarea', visible: false)
        expect(page).to have_link('Volver')
        expect(page).to have_link('Editar productos')
        expect(page).to have_button('Guardar y agregar productos')
        sleep 1
        within '#order-form' do
          select_sector(@depo_est_1.name, 'select#provider-sector')
          fill_in 'internal_order[observation]', with: 'Lorem ipsum'
        end
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La solicitud se ha modificado correctamente')
        add_products(rand(1..3), request_quantity: true, observations: true)
        click_button 'Enviar'
        expect(page).to have_content('La solicitud se ha enviado correctamente')
      end
    end
  end
end

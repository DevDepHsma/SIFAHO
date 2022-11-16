require 'rails_helper'

RSpec.feature 'Orders::Internal::Providers', type: :feature do
  before(:all) do
    perimssion_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Proveedor')
    @read_internal_order_provider = perimssion_module.permissions.find_by(name: 'read_internal_order_provider')
    @create_internal_order_provider = perimssion_module.permissions.find_by(name: 'create_internal_order_provider')
    @update_internal_order_provider = perimssion_module.permissions.find_by(name: 'update_internal_order_provider')
    @send_internal_order_provider = perimssion_module.permissions.find_by(name: 'send_internal_order_provider')
    @return_internal_order_provider = perimssion_module.permissions.find_by(name: 'return_internal_order_provider')
    @nullify_internal_order_provider = perimssion_module.permissions.find_by(name: 'nullify_internal_order_provider')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @create_internal_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @read_internal_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @update_internal_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @send_internal_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @return_internal_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @nullify_internal_order_provider)
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
        click_link 'Entregas'
        expect(page).to have_css('#table_results')
      end

      it 'show' do
        click_link 'Entregas'
        order = InternalOrder.where(status: 'proveedor_auditoria', order_type: 'solicitud',
                                    provider_sector_id: @farm_applicant.sector_id).first
        visit "/sectores/pedidos/despachos/#{order.id}"
        expect(page).to have_content('Solicitante')
        expect(page).to have_content('Proveedor')
        expect(page).to have_content('Solicitado')
        expect(page).to have_content('Código')
        expect(page).to have_content('Observaciones')
        expect(page).to have_link('Volver')
        expect(page).to have_link('Editar orden')
        expect(page).to have_link('Editar productos')
        expect(page).to have_link('Enviar provisión')
        expect(page).to have_button(class: 'btn btn-danger btn-sm')
      end

      it 'create' do
        within '#dropdown-menu-header' do
          expect(page).to have_link('Entregar')
          click_link 'Entregar'
        end
        expect(page).to have_content('Nueva provision de sector')
        expect(page).to have_content('Últimas entregas de sectores')
        expect(page).to have_select('internal_order[applicant_sector_id]', visible: false)
        expect(page).to have_field('internal_order[observation]', type: 'textarea', visible: false)
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar y agregar productos')
      end

      it 'edit' do
        within '#dropdown-menu-header' do
          expect(page).to have_link('Entregar')
          click_link 'Entregar'
        end
        within '#order-form' do
          select_sector(@depo_provider.sector.name, 'select#applicant-sector')
        end
        expect(page).to have_content(@depo_provider.sector.name)
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La provisión interna de Depósito se ha auditado correctamente.')
        expect(page).to have_content('Editando productos de provision de sector código')
        expect(page).to have_content('Solicitante')
        expect(page).to have_content(@farm_applicant.sector.name)
        expect(page).to have_content('Proveedor')
        expect(page).to have_content(@depo_provider.sector.name)
        expect(page).to have_content('Código')
        expect(page).to have_content('Producto')
        expect(page).to have_content('Unidad')
        expect(page).to have_content('Tu stock')
        expect(page).to have_content('Solicitado')
        expect(page).to have_content('Entregar')
        expect(page).to have_content('Tu observación')
        expect(page).to have_link('Volver')
        expect(page).to have_button('Enviar')
      end
    end

    describe 'Form' do
      before(:each) do
        visit 'sectores/pedidos/despachos'
      end
      it 'create' do
        click_link 'Entregar'
        within '#order-form' do
          select_sector(@depo_est_1.name, 'select#applicant-sector')
        end
        fill_in 'internal_order[observation]', with: 'Lorem ipsum'
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La provisión interna de Depósito se ha auditado correctamente.')
      end
      it 'charge products' do
        click_link 'Entregar'
        within '#order-form' do
          select_sector(@depo_est_1.name, 'select#applicant-sector')
        end
        fill_in 'internal_order[observation]', with: 'Lorem ipsum'
        click_button 'Guardar y agregar productos'
        add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
        click_button 'Enviar'
        expect(page).to have_content('Enviando provisión de sector')
        expect(page).to have_content('Una vez enviada la orden, no se podrán retornar los productos a stock.')
        expect(page).to have_content('Desea enviar la provisión?')
        expect(page).to have_button('Cancelar')
        expect(page).to have_link('Enviar')
        sleep 1
        within '.modal-content' do
          page.find('a', text: 'Enviar').click
        end

        expect(page).to have_content('La provision se ha enviado correctamente.')
      end

      it 'edit' do
        within '#internal_orders' do
          expect(page).to have_selector('tr')
          expect(page).to have_selector('.btn-edit')
          page.find('.btn-edit', match: :first).click
        end
        fill_in 'internal_order_observation', with: 'observación editada'
        click_button 'Guardar y agregar productos'
        expect(page).to have_content('La solicitud se ha editado y se encuentra en auditoria.')
        add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
        click_button 'Enviar'
        expect(page).to have_content('Enviando provisión de sector')
        expect(page).to have_content('Una vez enviada la orden, no se podrán retornar los productos a stock.')
        expect(page).to have_content('Desea enviar la provisión?')
        expect(page).to have_button('Cancelar')
        sleep 1
        within '.modal-content' do
          page.find('a', text: 'Enviar').click
        end
        expect(page).to have_content('La provision se ha enviado correctamente.')
        
       
      end
    end
  end
end

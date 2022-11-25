require 'rails_helper'

RSpec.feature 'Orders::Internal::Providers', type: :feature do
  background do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Proveedor')
    @read_internal_order_provider = permission_module.permissions.find_by(name: 'read_internal_order_provider')
    @create_internal_order_provider = permission_module.permissions.find_by(name: 'create_internal_order_provider')
    @update_internal_order_provider = permission_module.permissions.find_by(name: 'update_internal_order_provider')
    @send_internal_order_provider = permission_module.permissions.find_by(name: 'send_internal_order_provider')
    @return_internal_order_provider = permission_module.permissions.find_by(name: 'return_internal_order_provider')
    @destroy_internal_order_provider = permission_module.permissions.find_by(name: 'destroy_internal_order_provider')
    sign_in @depo_provider
  end

  describe 'Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Sectores')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @depo_provider, sector: @depo_provider.active_sector,
                              permission: @read_internal_order_provider)
        visit '/'
      end

      it ':: READ :: success' do
        expect(page.has_link?('Sectores')).to be true
      end

      describe '' do
        before(:each) do
          within '#sidebar-wrapper' do
            click_link 'Sectores'
          end
        end

        it 'has header links' do
          expect(page.has_link?('Recibos')).not_to be true
          expect(page.has_link?('Entregas')).to be true
          expect(page.has_link?('Solicitar')).not_to be true
          expect(page.has_link?('Entregar')).not_to be true
          expect(page.has_link?('Plantillas')).to be true
        end

        describe ':: CREATE' do
          it ':: fail' do
            visit '/sectores/pedidos/despachos/nuevo'
            expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
          end

          describe '' do
            before(:each) do
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.active_sector,
                                    permission: @create_internal_order_provider)
            end

            it ':: visit create form' do
              expect(page.has_link?('Entregar')).to be true
              click_link 'Entregar'
              expect(page).to have_content('Nueva provision de sector')
              expect(page).to have_content('Últimas entregas de sectores')
              expect(page.has_css?('select#applicant-sector', visible: false)).to be true
              expect(page.has_css?('textarea#internal_order_observation', visible: false)).to be true
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true

              within '#order-form' do
                select_sector(@farm_provider.active_sector.name, 'select#applicant-sector')
              end
              expect(page).to have_content(@farm_provider.active_sector.name)
              click_button 'Guardar y agregar productos'
              expect(page).to have_content('Editando productos de provision de sector código')
              expect(page).to have_content('Solicitante')
              expect(page).to have_content(@depo_provider.active_sector.name)
              expect(page).to have_content('Proveedor')
              expect(page).to have_content(@farm_provider.active_sector.name)
              expect(page).to have_content('Código')
              expect(page).to have_content('Producto')
              expect(page).to have_content('Unidad')
              expect(page).to have_content('Tu stock')
              expect(page).to have_content('Solicitad')
              expect(page).to have_content('Entregar')
              expect(page).to have_content('Tu observación')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false
            end
            it ':: visit update form' do
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.active_sector,
                                    permission: @update_internal_order_provider)
              3.times do |_rp|
                click_link 'Entregar'
                within '#order-form' do
                  select_sector(@farm_provider.active_sector.name, 'select#applicant-sector')
                end
                click_button 'Guardar y agregar productos'
                add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
                expect(page).to have_selector('input.product-code')
              end
              click_link 'Volver'
              within '#provider_orders' do
                expect(page).to have_selector('tr')
                expect(page).to have_selector('.btn-edit')
                page.execute_script %{$('a.btn-edit')[0].click()}
              end

              expect(page).to have_content('Editando provision de sector código')
              expect(page).to have_selector('#applicant-sector', visible: false)
              expect(page).to have_selector('textarea#internal_order_observation')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Editar productos')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true
              click_button 'Guardar y agregar productos'
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false

              # Add send permission
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.active_sector,
                                    permission: @send_internal_order_provider)
              visit current_path
              expect(page.has_button?('Enviar')).to be true
              click_button 'Enviar'
              # Confirmation modal
              expect(page).to have_content('Enviando provisión de sector')
              expect(page).to have_content('Una vez enviada la orden, no se podrán retornar los productos a stock.')
              expect(page).to have_content('Desea enviar la provisión?')
              expect(page.has_button?('Cancelar')).to be true
              expect(page.has_link?('Enviar')).to be true
              click_link 'Enviar'
              sleep 1
              expect(page).to have_content('La provision se ha enviado correctamente.')
              expect(page).to have_content('Provision en camino')
              expect(page).to have_content('Productos')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_button?('Retornar')).to be false

              # Destroy
              click_link 'Volver'
              click_link 'Entregar'
              within '#order-form' do
                select_sector(@farm_provider.active_sector.name, 'select#applicant-sector')
              end
              click_button 'Guardar y agregar productos'
              add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
              sleep 10
              click_link 'Volver'
              # Add destroy permission
              within '#provider_orders' do
                expect(page).not_to have_selector('.delete-item')
              end

              PermissionUser.create(user: @depo_provider, sector: @depo_provider.active_sector,
                                    permission: @destroy_internal_order_provider)
              visit current_path
              within '#provider_orders' do
                expect(page).to have_selector('.delete-item')
                page.execute_script %{$('button.delete-item')[0].click()}
                sleep 1
              end
              expect(page).to have_content('Eliminar provisión')
              expect(page.has_button?('Volver')).to be true
              expect(page.has_link?('Confirmar')).to be true
              click_link 'Confirmar'
              sleep 1
            end

            it 'Templates' do
              within '#dropdown-menu-header' do
                expect(page.has_link?('Plantillas')).to be true
                click_link 'Plantillas'
              end
              expect(page).not_to have_content('Plantillas de solicitud')
              expect(page).to have_content('Plantillas de despacho')
              expect(page.has_css?('#btn-provider-template')).to be true
              find('#btn-provider-template').click
              expect(page).to have_content('Agregar plantilla de provision a sector')
              expect(page.has_css?('#new_internal_order_template')).to be true

              fill_order_template(
                form_id: '#new_internal_order_template',
                template_name_input: 'internal_order_template_name',
                template_name: 'Template Test',
                sector_input: 'provider-sector',
                sector: @farm_provider.active_sector,
                products_size: 3
              )

              expect(page.has_button?('Guardar')).to be true
              click_button 'Guardar'
              expect(page).to have_content('Viendo plantilla de provision')
              expect(page.has_css?('.delete-item')).to be true
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_link?('Editar')).to be true
              expect(page.has_link?('Crear despacho')).to be true
              click_link 'Editar'
              expect(page).to have_content('Editar plantilla de provision a sector')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Guardar')).to be true
              click_link 'Volver'
              expect(page).to have_content('Template Test')
            end
          end
        end
      end
    end
  end
end

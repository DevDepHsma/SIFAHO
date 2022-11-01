require 'rails_helper'

RSpec.feature 'Orders::External::Providers', type: :feature do
  background do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Externas Proveedor')
    @read_external_order_provider = permission_module.permissions.find_by(name: 'read_external_order_provider')
    @create_external_order_provider = permission_module.permissions.find_by(name: 'create_external_order_provider')
    @update_external_order_provider = permission_module.permissions.find_by(name: 'update_external_order_provider')
    @accept_external_order_provider = permission_module.permissions.find_by(name: 'accept_external_order_provider')
    @send_external_order_provider = permission_module.permissions.find_by(name: 'send_external_order_provider')
    @return_external_order_provider = permission_module.permissions.find_by(name: 'return_external_order_provider')
    @destroy_external_order_provider = permission_module.permissions.find_by(name: 'destroy_external_order_provider')
    sign_in @depo_provider
  end

  describe 'Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Establecimientos')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @depo_provider, sector: @depo_provider.sector,
                              permission: @read_external_order_provider)
        visit '/'
      end

      it ':: READ :: success' do
        expect(page.has_link?('Establecimientos')).to be true
      end

      describe '' do
        before(:each) do
          within '#sidebar-wrapper' do
            click_link 'Establecimientos'
          end
        end

        it 'has header links' do
          expect(page.has_link?('Establecimientos')).to be true
          expect(page.has_link?('Despachos')).to be true
          expect(page.has_link?('Recibos')).not_to be true
          expect(page.has_link?('Solicitar')).not_to be true
          expect(page.has_link?('Despachar')).not_to be true
          expect(page.has_link?('Plantillas')).to be true
        end

        describe ':: CREATE' do
          it ':: fail' do
            visit '/establecimientos/pedidos/despachos/nuevo'
            expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
          end

          describe '' do
            before(:each) do
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.sector,
                                    permission: @create_external_order_provider)
            end

            it ':: visit create form' do
              expect(page.has_link?('Despachar')).to be true
              click_link 'Despachar'
              expect(page).to have_content('Nueva provision de establecimiento')
              expect(page).to have_content('Aún no hay despachos realizados')
              expect(page.has_css?('input#effector-establishment', visible: false)).to be true
              expect(page.has_css?('select#effector-sector', visible: false)).to be true
              expect(page).to have_selector('textarea#external_order_provider_observation')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true

              select_sector(@farm_applicant.sector.name, 'select#effector-sector', @farm_applicant.establishment)
              click_button 'Guardar y agregar productos'
              expect(page).to have_content('La provisión se ha creado y se encuentra en auditoria.')
              expect(page).to have_content('Editando provision de establecimiento código')
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
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Aceptar')).to be false
            end
            it ':: visit edit form' do
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.sector,
                                    permission: @update_external_order_provider)
              3.times do |_rp|
                click_link 'Despachar'
                select_sector(@farm_applicant.sector.name, 'select#effector-sector', @farm_applicant.establishment)
                click_button 'Guardar y agregar productos'
                visit current_path
                add_products(rand(1..3), request_quantity: true, observations: true, select_lot_stock: true)
                expect(page).to have_selector('input.product-code')
              end
              click_link 'Volver'
              within '#external_orders' do
                expect(page).to have_selector('tr')
                expect(page).to have_selector('.btn-edit')
                page.execute_script %{$('a.btn-edit')[0].click()}
              end

              expect(page).to have_content('Editando provision de establecimiento código')
              expect(page.has_css?('input#effector-establishment', visible: false)).to be true
              expect(page.has_css?('select#effector-sector', visible: false)).to be true
              expect(page).to have_selector('textarea#external_order_provider_observation')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Editar productos')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true
              click_button 'Guardar y agregar productos'
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Aceptar')).to be false

              # Add send permission
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.sector,
                                    permission: @accept_external_order_provider)
              visit current_path
              expect(page.has_button?('Aceptar')).to be true
              click_button 'Aceptar'
              expect(page).to have_content('La provision se ha aceptado correctamente.')
              expect(page).to have_content('Proveedor aceptado')
              expect(page).to have_content('Productos')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_button?('Retornar')).to be false
              expect(page.has_button?('Enviar provisión')).to be false
              # Add return permission
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.sector,
                                    permission: @send_external_order_provider)
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.sector,
                                    permission: @return_external_order_provider)
              visit current_path
              expect(page.has_button?('Enviar provisión')).to be true
              expect(page.has_button?('Retornar')).to be true
              click_button 'Retornar'
              sleep 1
              expect(page).to have_content('Retornar a proveedor auditoria')
              expect(page.has_link?('Cancelar')).to be true
              expect(page.has_link?('Confirmar')).to be true
              click_link 'Confirmar'
              expect(page).to have_content('Proveedor auditoria')
              click_link 'Volver'
              within '#external_orders' do
                expect(page).to have_selector('.btn-detail')
              end
              # Add destroy permission
              PermissionUser.create(user: @depo_provider, sector: @depo_provider.sector,
                                    permission: @destroy_external_order_provider)
              visit current_path
              within '#external_orders' do
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
              expect(page).to have_content('Agregar plantilla de provision a establecimiento')
              expect(page.has_css?('#new_external_order_template')).to be true

              fill_order_template(
                form_id: '#new_external_order_template',
                template_name_input: 'external_order_template_name',
                template_name: 'Template Test',
                establishment_input: 'provider-establishment',
                sector_input: 'provider-sector',
                sector: @farm_applicant.sector,
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
              expect(page).to have_content('Editar plantilla de provision a establecimiento')
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

require 'rails_helper'

RSpec.feature "Orders::External::Providers", type: :feature do
  background do
    sign_in_as(@provider_user)
  end

  describe 'Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Establecimientos')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @read_external_order_provider)
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
          expect(page.has_link?('Plantillas')).not_to be true
        end

        describe ':: CREATE' do
          it ':: fail' do
            visit '/establecimientos/pedidos/despachos/nuevo'
            expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
          end

          describe '' do
            before(:each) do
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @create_external_order_provider)
            end

            it ':: visit create form' do
              expect(page.has_link?('Despachar')).to be true
              click_link 'Despachar'
              expect(page).to have_content('Nueva provision de establecimiento')
              expect(page).to have_content('Aún no hay despachos realizadas')
              expect(page.has_css?('input#effector-establishment', visible: false)).to be true
              expect(page.has_css?('select#effector-sector', visible: false)).to be true
              expect(page).to have_selector('textarea#external_order_provider_observation')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true

              select_sector(@farmacia_other_establishment.name, 'select#effector-sector', @other_establishment)
              expect(page).to have_content(@deposito.name)
              click_button 'Guardar y agregar productos'
              expect(page).to have_content('La provisión se ha creado y se encuentra en auditoria.')
              expect(page).to have_content('Editando provision de establecimiento código')
              expect(page).to have_content('Solicitante')
              expect(page).to have_content(@farmacia_other_establishment.name)
              expect(page).to have_content('Proveedor')
              expect(page).to have_content(@deposito.name)
              expect(page).to have_content('Código')
              expect(page).to have_content('Producto')
              expect(page).to have_content('Unidad')
              expect(page).to have_content('Tu stock')
              expect(page).to have_content('Solicitado')
              expect(page).to have_content('Entregar')
              expect(page).to have_content('Tu observación')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Aceptar')).to be false

              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @update_external_order_provider)
              visit current_path
              prods = @products.sample(3)
              add_products(prods, request_quantity: true, observations: true, select_lot_stock: true)
              expect(page).to have_selector('input.product-code', count: 3)
              click_link 'Volver'
              within '#external_orders' do
                expect(page).to have_selector('tr', count: 1)
                expect(page).to have_selector('.btn-edit', count: 1)
                page.execute_script %Q{$('a.btn-edit')[0].click()}
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
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @accept_external_order_provider)
              visit current_path
              expect(page.has_button?('Aceptar')).to be true
              click_button 'Aceptar'
              expect(page).to have_content('La provision se ha aceptado correctamente.')
              expect(page).to have_content('Proveedor aceptado')
              expect(page).to have_content('Productos 3')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_button?('Retornar')).to be false
              expect(page.has_button?('Enviar provisión')).to be false
              # Add return permission
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @send_external_order_provider)
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @return_external_order_provider)
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
                expect(page).to have_selector('.btn-detail', count: 1)
              end
              # Add destroy permission
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @destroy_external_order_provider)
              visit current_path
              within '#external_orders' do
                expect(page).to have_selector('.delete-item', count: 1)
                page.execute_script %Q{$('button.delete-item')[0].click()}
                sleep 1
              end
              expect(page).to have_content('Eliminar provisión')
              expect(page.has_button?('Volver')).to be true
              expect(page.has_link?('Confirmar')).to be true
              click_link 'Confirmar'
              sleep 1
              within '#external_orders' do
                expect(page).to have_selector('.delete-item', count: 0)
              end
            end
          end
        end
      end
    end
  end
end

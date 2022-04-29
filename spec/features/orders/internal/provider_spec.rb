require 'rails_helper'

RSpec.feature "Orders::Internal::Providers", type: :feature do
  background do
    sign_in_as(@provider_user)
  end

  describe 'Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Sectores')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @read_internal_order_provider)
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
          expect(page.has_link?('Plantillas')).not_to be true
        end

        describe ':: CREATE' do
          it ':: fail' do
            visit '/sectores/pedidos/despachos/nuevo'
            expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
          end

          describe '' do
            before(:each) do
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @create_internal_order_provider)
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
                select_sector(@farmacia.name, 'select#applicant-sector')
              end
              expect(page).to have_content(@farmacia.name)
              click_button 'Guardar y agregar productos'
              expect(page).to have_content('Editando productos de provision de sector código')
              expect(page).to have_content('Solicitante')
              expect(page).to have_content(@deposito.name)
              expect(page).to have_content('Proveedor')
              expect(page).to have_content(@farmacia.name)
              expect(page).to have_content('Código')
              expect(page).to have_content('Producto')
              expect(page).to have_content('Unidad')
              expect(page).to have_content('Tu stock')
              expect(page).to have_content('Solicitad')
              expect(page).to have_content('Entregar')
              expect(page).to have_content('Tu observación')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @update_internal_order_provider)
              visit current_path
              prods = @products.sample(4)
              add_products(prods, request_quantity: true, observations: true, select_lot_stock: true)
              expect(page).to have_selector('input.product-code', count: 4)
              sleep 1
              click_link 'Volver'
              within '#provider_orders' do
                expect(page).to have_selector('tr', count: 1)
                expect(page).to have_selector('.btn-edit', count: 1)
                page.execute_script %Q{$('a.btn-edit')[0].click()}
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
              PermissionUser.create(user: @provider_user, sector: @provider_user.sector, permission: @send_internal_order_provider)
              visit current_path
              expect(page.has_button?('Enviar')).to be true
              click_button 'Enviar'
              # Confirmation modal
              expect(page).to have_content('Enviando provisión de sector')
              expect(page).to have_content('Una vez enviada la orden, no se podrán retornar los productos a stock.')
              expect(page).to have_content('Desea enviar la provisión?')
              expect(page.has_button?('Volver')).to be true
              expect(page.has_link?('Enviar')).to be true
              clink_link 'Enviar'
              sleep 1
              expect(page).to have_content('La provision se ha enviado correctamente.')
              expect(page).to have_content('Provision en camino')
              expect(page).to have_content('Productos 4')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_button?('Retornar')).to be false
              # Add return permission
              PermissionUser.create(user: @user, sector: @user.sector, permission: @return_internal_order_applicant)
              visit current_path
              expect(page.has_button?('Retornar')).to be true
              click_button 'Retornar'
              sleep 1
              expect(page).to have_content('Retornar a solicitud auditoria')
              expect(page.has_link?('Cancelar')).to be true
              expect(page.has_link?('Confirmar')).to be true
              click_link 'Confirmar'
              expect(page).to have_content('Solicitud auditoria')
              click_link 'Volver'
              within '#applicant_orders' do
                expect(page).not_to have_selector('.delete-item', count: 1)
              end
              # Add destroy permission
              PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_internal_order_applicant)
              visit current_path
              within '#applicant_orders' do
                expect(page).to have_selector('.delete-item', count: 1)
                page.execute_script %Q{$('button.delete-item')[0].click()}
                sleep 1
              end
              expect(page).to have_content('Eliminar solicitud')
              expect(page.has_button?('Volver')).to be true
              expect(page.has_link?('Confirmar')).to be true
              click_link 'Confirmar'
              sleep 1
              within '#applicant_orders' do
                expect(page).to have_selector('.delete-item', count: 0)
              end
            end
          end
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.feature 'Orders::Internal::Applicants', type: :feature do
  background do
    perimssion_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Solicitud')
    @read_internal_order_applicant = perimssion_module.permissions.find_by(name: 'read_internal_order_applicant')
    @create_internal_order_applicant = perimssion_module.permissions.find_by(name: 'create_internal_order_applicant')
    @update_internal_order_applicant = perimssion_module.permissions.find_by(name: 'update_internal_order_applicant')
    @send_internal_order_applicant = perimssion_module.permissions.find_by(name: 'send_internal_order_applicant')
    @return_internal_order_applicant = perimssion_module.permissions.find_by(name: 'return_internal_order_applicant')
    @destroy_internal_order_applicant = perimssion_module.permissions.find_by(name: 'destroy_internal_order_applicant')
    sign_in_as(@farm_applicant)
  end

  describe 'Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Sectores')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_internal_order_applicant)
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
          expect(page.has_link?('Recibos')).to be true
          expect(page.has_link?('Entregas')).not_to be true
          expect(page.has_link?('Solicitar')).not_to be true
          expect(page.has_link?('Entregar')).not_to be true
          expect(page.has_link?('Plantillas')).not_to be true
        end

        describe ':: CREATE' do
          it ':: fail' do
            visit '/sectores/pedidos/recibos/nuevo'
            expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
          end

          describe '' do
            before(:each) do
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_internal_order_applicant)
            end

            it ':: visit create form' do
              expect(page.has_link?('Solicitar')).to be true
              click_link 'Solicitar'
              expect(page).to have_content('Nueva solicitud de sector')
              expect(page).to have_content('Últimas solicitudes de sectores')
              expect(page.has_css?('select#provider-sector', visible: false)).to be true
              expect(page.has_css?('textarea#internal_order_observation', visible: false)).to be true
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true

              within '#order-form' do
                select_sector(@depo_applicant.sector.name, 'select#provider-sector')
              end
              expect(page).to have_content(@depo_applicant.sector.name)
              click_button 'Guardar y agregar productos'
              expect(page).to have_content('Editando productos de solicitud de sector código')
              expect(page).to have_content('Solicitante')
              expect(page).to have_content(@farm_applicant.sector.name)
              expect(page).to have_content('Proveedor')
              expect(page).to have_content(@depo_applicant.sector.name)
              expect(page).to have_content('Código')
              expect(page).to have_content('Producto')
              expect(page).to have_content('Unidad')
              expect(page).to have_content('Tu stock')
              expect(page).to have_content('Solicitar')
              expect(page).to have_content('Tu observación')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false

              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_internal_order_applicant)
              visit current_path
              add_products(rand(1..3), request_quantity: true, observations: true)
              expect(page).to have_selector('input.product-code')
              click_link 'Volver'
              within '#applicant_orders' do
                expect(page).to have_selector('tr')
                expect(page).to have_selector('.btn-edit')
                page.execute_script %Q{$('a.btn-edit')[0].click()}
              end

              expect(page).to have_content('Editando solicitud de sector código')
              expect(page).to have_selector('#provider-sector', visible: false)
              expect(page).to have_selector('textarea#internal_order_observation')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Editar productos')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true
              click_button 'Guardar y agregar productos'
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false

              # Add send permission
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @send_internal_order_applicant)
              visit current_path
              expect(page.has_button?('Enviar')).to be true
              click_button 'Enviar'
              expect(page).to have_content('La solicitud se ha enviado correctamente.')
              expect(page).to have_content('Solicitud enviada')
              expect(page).to have_content('Productos')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_button?('Retornar')).to be false
              # Add return permission
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @return_internal_order_applicant)
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
                expect(page).not_to have_selector('.delete-item')
              end
              # Add destroy permission
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_internal_order_applicant)
              visit current_path
              within '#applicant_orders' do
                expect(page).to have_selector('.delete-item')
                page.execute_script %Q{$('button.delete-item')[0].click()}
                sleep 1
              end
              expect(page).to have_content('Eliminar solicitud')
              expect(page.has_button?('Volver')).to be true
              expect(page.has_link?('Confirmar')).to be true
              click_link 'Confirmar'
              sleep 1
            end
          end
        end
      end
    end
  end
end

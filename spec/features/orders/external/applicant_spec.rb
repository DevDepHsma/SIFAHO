require 'rails_helper'

RSpec.feature 'Orders::External::Applicants', type: :feature do
  background do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Externas Solicitud')
    @read_external_order_applicant = permission_module.permissions.find_by(name: 'read_external_order_applicant')
    @create_external_order_applicant = permission_module.permissions.find_by(name: 'create_external_order_applicant')
    @update_external_order_applicant = permission_module.permissions.find_by(name: 'update_external_order_applicant')
    @send_external_order_applicant = permission_module.permissions.find_by(name: 'send_external_order_applicant')
    @return_external_order_applicant = permission_module.permissions.find_by(name: 'return_external_order_applicant')
    @destroy_external_order_applicant = permission_module.permissions.find_by(name: 'destroy_external_order_applicant')
    sign_in_as(@farm_applicant)
  end

  describe 'Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Establecimientos')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                              permission: @read_external_order_applicant)
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
          expect(page.has_link?('Recibos')).to be true
          expect(page.has_link?('Despachos')).not_to be true
          expect(page.has_link?('Solicitar')).not_to be true
          expect(page.has_link?('Despachar')).not_to be true
          expect(page.has_link?('Plantillas')).to be true
        end

        describe ':: CREATE' do
          it ':: fail' do
            visit '/establecimientos/pedidos/recibos/nuevo'
            expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
          end

          describe '' do
            before(:each) do
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                    permission: @create_external_order_applicant)
            end

            it ':: visit create form' do
              expect(page.has_link?('Solicitar')).to be true
              click_link 'Solicitar'
              expect(page).to have_content('Nueva solicitud de establecimiento')
              expect(page).to have_content('Aún no hay solicitudes realizadas')
              expect(page.has_css?('input#effector-establishment', visible: false)).to be true
              expect(page.has_css?('select#effector-sector', visible: false)).to be true
              expect(page.has_css?('textarea#external_order_applicant_observation', visible: false)).to be true
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true

              select_sector(@depo_provider.sector.name, 'select#effector-sector', @depo_provider.establishment)
              expect(page).to have_content(@depo_provider.sector.name)
              click_button 'Guardar y agregar productos'
              expect(page).to have_content('La solicitud de abastecimiento se ha creado y se encuentra en auditoría.')
              expect(page).to have_content('Editando solicitud de establecimiento código')
              expect(page).to have_content('Solicitante')
              expect(page).to have_content(@farm_applicant.sector.name)
              expect(page).to have_content('Proveedor')
              expect(page).to have_content(@depo_provider.sector.name)
              expect(page).to have_content('Código')
              expect(page).to have_content('Producto')
              expect(page).to have_content('Unidad')
              expect(page).to have_content('Tu stock')
              expect(page).to have_content('Solicitar')
              expect(page).to have_content('Tu observación')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false

              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                    permission: @update_external_order_applicant)
              visit current_path
              add_products(rand(1..3), request_quantity: true, observations: true)
              expect(page).to have_selector('input.product-code')
              click_link 'Volver'
              within '#applicant_orders' do
                expect(page).to have_selector('tr')
                expect(page).to have_selector('.btn-edit')
                page.execute_script %{$('a.btn-edit')[0].click()}
              end

              expect(page).to have_content('Editando solicitud de establecimiento código')
              expect(page.has_css?('input#effector-establishment', visible: false)).to be true
              expect(page.has_css?('select#effector-sector', visible: false)).to be true
              expect(page).to have_selector('textarea#external_order_applicant_observation')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Editar productos')).to be true
              expect(page.has_button?('Guardar y agregar productos')).to be true
              click_button 'Guardar y agregar productos'
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false

              # Add send permission
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                    permission: @send_external_order_applicant)
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
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                    permission: @return_external_order_applicant)
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
              PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                    permission: @destroy_external_order_applicant)
              visit current_path
              within '#applicant_orders' do
                expect(page).to have_selector('.delete-item')
                page.execute_script %{$('button.delete-item')[0].click()}
                sleep 1
              end
              expect(page).to have_content('Eliminar solicitud')
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
              expect(page).to have_content('Plantillas de solicitud')
              expect(page).not_to have_content('Plantillas de despacho')
              expect(page.has_css?('#btn-applicant-template')).to be true
              find('#btn-applicant-template').click
              expect(page).to have_content('Agregar plantilla de solicitud a establecimiento')
              expect(page.has_css?('#new_external_order_template')).to be true

              fill_order_template(
                form_id: '#new_external_order_template',
                template_name_input: 'external_order_template_name',
                template_name: 'Template Test',
                establishment_input: 'provider-establishment',
                sector_input: 'provider-sector',
                sector: @depo_provider.sector,
                products_size: 3
              )

              expect(page.has_button?('Guardar')).to be true
              click_button 'Guardar'
              sleep 10
              expect(page).to have_content('Viendo plantilla de solicitud')
              expect(page.has_css?('.delete-item')).to be true
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_link?('Editar')).to be true
              expect(page.has_link?('Crear solicitud')).to be true
              click_link 'Editar'
              expect(page).to have_content('Editar plantilla de solicitud a establecimiento')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Guardar')).to be true
              click_link 'Volver'
              expect(page).to have_content('Template Test')
              sleep 15
            end
          end
        end
      end
    end
  end
end

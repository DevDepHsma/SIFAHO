require 'rails_helper'

RSpec.feature "Orders::External::Applicants", type: :feature do
  before(:all) do
    @establishment = create(:establishment_1)
    @other_establishment = create(:establishment_2)
    @farmacia = create(:sector_1, establishment: @establishment)
    @deposito = create(:sector_4, establishment: @other_establishment)
    @user = create(:user_1, sector: @farmacia)
    @permission_module = create(:permission_module, name: 'Ordenes Externas Solicitud')
    @read_external_order_applicant = create(:permission, name: 'read_external_order_applicant', permission_module: @permission_module)
    @create_external_order_applicant = create(:permission, name: 'create_external_order_applicant', permission_module: @permission_module)
    @update_external_order_applicant = create(:permission, name: 'update_external_order_applicant', permission_module: @permission_module)
    @destroy_external_order_applicant = create(:permission, name: 'destroy_external_order_applicant', permission_module: @permission_module)
    @send_external_order_applicant = create(:permission, name: 'send_external_order_applicant', permission_module: @permission_module)
    @receive_external_order_applicant = create(:permission, name: 'receive_external_order_applicant', permission_module: @permission_module)
    @return_external_order_applicant = create(:permission, name: 'return_external_order_applicant', permission_module: @permission_module)

    @products = get_products
    @unity = create(:unidad_unity)
    @area = create(:medication_area)
    @lab = create(:abbott_laboratory)
    @products.each_with_index do |product, index|
      prod = create(:product, name: product[0], code: product[1], area: @area, unity: @unity)
      lot = create(:lot, laboratory: @lab, product: prod, code: "BB-#{index}", expiry_date:  Date.today + 15.month)
      stock = create(:stock, product: prod, sector: @user.sector)
      LotStock.create(quantity: rand(1500..5000), lot: lot, stock: stock)
    end
  end

  background do
    sign_in_as(@user)
  end

  describe 'Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Establecimientos')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_external_order_applicant)
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
          expect(page.has_link?('Plantillas')).not_to be true
        end

        describe ':: CREATE' do
          it ':: fail' do
            visit '/establecimientos/pedidos/recibos/nuevo'
            expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
          end

          describe '' do
            before(:each) do
              PermissionUser.create(user: @user, sector: @user.sector, permission: @create_external_order_applicant)
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

              select_sector(@deposito.name, 'select#effector-sector', @other_establishment)
              expect(page).to have_content(@deposito.name)
              click_button 'Guardar y agregar productos'
              expect(page).to have_content('La solicitud de abastecimiento se ha creado y se encuentra en auditoría.')
              expect(page).to have_content('Editando solicitud de establecimiento código')
              expect(page).to have_content('Solicitante')
              expect(page).to have_content(@farmacia.name)
              expect(page).to have_content('Proveedor')
              expect(page).to have_content(@deposito.name)
              expect(page).to have_content('Código')
              expect(page).to have_content('Producto')
              expect(page).to have_content('Unidad')
              expect(page).to have_content('Tu stock')
              expect(page).to have_content('Solicitar')
              expect(page).to have_content('Tu observación')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_button?('Enviar')).to be false

              PermissionUser.create(user: @user, sector: @user.sector, permission: @update_external_order_applicant)
              visit current_path
              add_products(@products, 3, request_quantity: true, observations: true)
              expect(page).to have_selector('input.product-code', count: 3)
              click_link 'Volver'
              within '#applicant_orders' do
                expect(page).to have_selector('tr', count: 1)
                expect(page).to have_selector('.btn-edit', count: 1)
                page.execute_script %Q{$('a.btn-edit')[0].click()}
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
              PermissionUser.create(user: @user, sector: @user.sector, permission: @send_external_order_applicant)
              visit current_path
              expect(page.has_button?('Enviar')).to be true
              click_button 'Enviar'
              expect(page).to have_content('La solicitud se ha enviado correctamente.')
              expect(page).to have_content('Solicitud enviada')
              expect(page).to have_content('Productos 3')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_button?('Retornar')).to be false
              # Add return permission
              PermissionUser.create(user: @user, sector: @user.sector, permission: @return_external_order_applicant)
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
              PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_external_order_applicant)
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

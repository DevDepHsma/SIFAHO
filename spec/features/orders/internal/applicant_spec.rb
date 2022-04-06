require 'rails_helper'

RSpec.feature 'Orders::Internal::Applicants', type: :feature do
  before(:all) do
    @establishment =  create(:establishment_1)
    @farmacia = create(:sector_1, establishment: @establishment)
    @deposito = create(:sector_4, establishment: @establishment)
    @user = create(:user_1, sector: @farmacia)
    @permission_module = create(:permission_module, name: 'Ordenes Internas Solicitud')
    @read_internal_order_applicant = create(:permission, name: 'read_internal_order_applicant', permission_module: @permission_module)
    @create_internal_order_applicant = create(:permission, name: 'create_internal_order_applicant', permission_module: @permission_module)
    @update_internal_order_applicant = create(:permission, name: 'update_internal_order_applicant', permission_module: @permission_module)
    @destroy_internal_order_applicant = create(:permission, name: 'destroy_internal_order_applicant', permission_module: @permission_module)
    @send_internal_order_applicant = create(:permission, name: 'send_internal_order_applicant', permission_module: @permission_module)
    @receive_internal_order_applicant = create(:permission, name: 'receive_internal_order_applicant', permission_module: @permission_module)
    @return_internal_order_applicant = create(:permission, name: 'return_internal_order_applicant', permission_module: @permission_module)

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

  describe 'InternalOrder :: Permissions', js: true do
    subject { page }

    it ':: READ :: fail' do
      expect(page.has_link?('Sectores')).to_not be true
    end

    describe '' do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_internal_order_applicant)
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
              PermissionUser.create(user: @user, sector: @user.sector, permission: @create_internal_order_applicant)
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
            # end

            # it ':: success' do
              within '#order-form' do
                select_sector(@deposito.name, 'select#provider-sector')
              end
              expect(page).to have_content(@deposito.name)
              click_button 'Guardar y agregar productos'
            end
          end
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.feature 'Permissions::OutpatientPrescriptions', type: :feature do

  before(:all) do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Recetas Ambulatorias')
    @read_outpatient_permission = create(:permission, name: 'read_outpatient_recipes', permission_module: @permission_module)
    @dispense_recipe_permission = create(:permission, name: 'dispense_outpatient_recipes', permission_module: @permission_module)
    @return_recipe_permission = create(:permission, name: 'return_outpatient_recipes', permission_module: @permission_module)
    @update_recipe_permission = create(:permission, name: 'update_outpatient_recipes', permission_module: @permission_module)

    @professionals_permission_module = create(:permission_module, name: 'Profesionales')
    @create_professional_permission = create(:permission, name: 'create_professionals', permission_module: @professionals_permission_module)
    PermissionUser.create(user: @user, sector: @user.sector, permission: @create_professional_permission)
    product = create(:unidad_product)
    lot = create(:province_lot_without_product, product: product)
    stock = create(:stock, product: product, sector: @user.sector)
    @lot_stock = LotStock.create(quantity: 1500, lot: lot, stock: stock)
  end

  background do
    sign_in_as(@user)
  end

  describe 'GET / (home page)', js: true do

    subject { page }

    it 'does not show "Recetas" link button' do
      visit '/'
      expect(page).to_not have_selector(:css, "a[href='#{prescriptions_path}']")
    end

    describe 'GET /recetas (recipes page)' do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_outpatient_permission)
      end

      it 'shows "Recetas" link button' do
        visit '/'
        expect(page).to have_selector(:css, "a[href='#{prescriptions_path}']")
      end

      describe 'Create action outpatient recipe' do
        before(:each) do
          visit '/'
          click_link 'Recetas'
          find_or_create_patient_by_dni('Ambulatorias', '37458994')
        end

        it 'does not show "+ Ambulatoria" link button' do
          expect(page.has_css?('#new-outpatient')).to be false
        end

        describe 'Create action outpatient recipe' do
          before(:each) do
            PermissionUser.create(user: @user, sector: @user.sector, permission: @dispense_recipe_permission)
          end

          it 'shows "+ Ambulatoria" link button' do
            expect(page.has_css?('#new-outpatient')).to be true
            find(:css, '#new-outpatient').click
            expect(page).to have_content('Agregar receta ambulatoria')
            expect(page).to have_content('37458994')
            expect(page.has_css?('input#professional')).to be true
            expect(page.has_css?('input#outpatient_prescription_date_prescribed')).to be true
            expect(page.has_css?('textarea#outpatient_prescription_observation')).to be true
            expect(page.has_css?('#order-product-cocoon-container')).to be true
            expect(page.has_field?('Código', type: 'text')).to be true
            expect(page.has_field?('Nombre', type: 'text')).to be true
            expect(page.has_css?('input#outpatient_prescription_outpatient_prescription_products_attributes_0_request_quantity')).to be true
            expect(page.has_css?('input#outpatient_prescription_outpatient_prescription_products_attributes_0_delivery_quantity')).to be true
            expect(page.has_link?('Agregar insumo')).to be true
            expect(page.has_button?('Dispensar')).to be true
          end

          describe 'save new outpatient recipe' do
            before(:each) do
              find_or_create_professional_by_enrollment(@user, '#new-outpatient', 'Naval')
            end

            it 'create recipe' do
              # Add product
              expect(page.has_css?('#professional')).to be true
              within '#order-product-cocoon-container' do
                page.execute_script %Q{$('input[name="product_code_fake-"]').val('0000').keydown()}
                sleep 2
              end
              expect(find('ul.ui-autocomplete')).to have_content('0000')
              page.execute_script("$('.ui-menu-item:contains(\"0000\")').first().click()")
              sleep 1
              within '#order-product-cocoon-container' do
                page.execute_script %Q{$('input.request-quantity').first().val(100).keydown()}
                page.execute_script %Q{$('input.deliver-quantity').first().val(100).keydown()}
                page.execute_script %Q{$('button.select-lot-btn').first().click()}
                sleep 1
              end
              # Select a lot
              expect(page.has_css?('#table-lot-selection')).to be true
              within '#lot-selection' do
                page.execute_script %Q{$('input[name="lot-quantity[0]"]').click().val(100)}
                click_button 'Volver'
              end
              sleep 1
              # Dispense
              click_button 'Dispensar'
              expect(page).to have_content('Viendo receta ambulatoria')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Imprimir')).to be true
              expect(page.has_button?('Retornar')).to be false
              expect(page.has_link?('Dispensar')).to be false
              expect(page.has_link?('Editar')).to be false

              # Add return permission
              PermissionUser.create(user: @user, sector: @user.sector, permission: @return_recipe_permission)
              visit current_path

              # Return recipe
              expect(page.has_button?('Retornar')).to be true
              click_button 'Retornar'
              sleep 1
              expect(page).to have_content('Retornar a Pendiente')
              within '#return-confirm' do
                click_link 'Confirmar'
              end
              expect(page.has_link?('Dispensar')).to be true

              # Add Edition action
              PermissionUser.create(user: @user, sector: @user.sector, permission: @update_recipe_permission)
              visit current_path

              expect(page.has_link?('Editar')).to be true
              click_link 'Editar'

              expect(page).to have_content('Editando receta ambulatoria')
              within '#order-product-cocoon-container' do
                page.execute_script %Q{$('input.request-quantity').first().val(50).keydown()}
                page.execute_script %Q{$('input.deliver-quantity').first().val(50).keydown()}
                page.execute_script %Q{$('button.select-lot-btn').first().click()}
                sleep 1
              end
              # Select a lot
              expect(page.has_css?('#table-lot-selection')).to be true
              within '#lot-selection' do
                page.execute_script %Q{$('input[name="lot-quantity[0]"]').click().val(50)}
                click_button 'Volver'
              end
              click_button 'Dispensar'
              expect(page).to have_content('Viendo receta ambulatoria')
            end
          end
        end
      end
    end
  end
end
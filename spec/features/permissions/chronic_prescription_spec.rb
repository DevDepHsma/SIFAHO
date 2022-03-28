require 'rails_helper'

RSpec.feature 'Permissions::ChronicPrescriptions', type: :feature do

  before(:all) do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Recetas Crónicas')
    @read_chronic_recipe_permission = create(:permission, name: 'read_chronic_prescriptions', permission_module: @permission_module)
    @create_chronic_recipe_permission = create(:permission, name: 'create_chronic_prescriptions', permission_module: @permission_module)
    @dispense_chronic_recipe_permission = create(:permission, name: 'dispense_chronic_prescriptions', permission_module: @permission_module)
    @return_chronic_recipe_permission = create(:permission, name: 'return_chronic_prescriptions', permission_module: @permission_module)

    # Create scenario with professional form completed
    @professionals_permission_module = create(:permission_module, name: 'Profesionales')
    @create_professional_permission = create(:permission, name: 'create_professionals', permission_module: @professionals_permission_module)
    PermissionUser.create(user: @user, sector: @user.sector, permission: @create_professional_permission)
    @product = create(:unidad_product)
    lot = create(:province_lot_without_product, product: @product)
    stock = create(:stock, product: @product, sector: @user.sector)
    @lot_stock = LotStock.create(quantity: 1500, lot: lot, stock: stock)
  end

  background do
    sign_in_as(@user)
  end

  describe 'Chronic Recipes ::', js: true do
    subject { page }

    it 'does not show "Recetas" link' do
      visit '/'
      expect(page).to_not have_selector(:css, "a[href='#{new_prescription_path}']")
    end

    describe 'Add permissions ::' do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_chronic_recipe_permission)
      end

      it 'can READ' do
        visit '/'
        expect(page).to have_selector(:css, "a[href='#{new_prescription_path}']")
      end

      describe 'CREATE ::' do
        before(:each) do
          visit '/'
          click_link 'Recetas'
          find_or_create_patient_by_dni('Crónicas', '37458994')
        end

        it 'does not show create chronic recipe' do
          expect(page.has_css?('#new-chronic')).to be false
        end

        describe '' do
          before(:each) do
            PermissionUser.create(user: @user, sector: @user.sector, permission: @create_chronic_recipe_permission)
            find_or_create_professional_by_enrollment(@user, '#new-chronic', 'Naval')
          end

          it 'successfully' do
            # Add product
            add_original_product_by_code('0000', 1)
            click_button 'Guardar'
            expect(page).to have_content('Viendo receta crónica')
            expect(page.has_link?('Volver')).to be true
            expect(page.has_link?('Dispensar')).to be false

            # Create a dispense
            PermissionUser.create(user: @user, sector: @user.sector, permission: @dispense_chronic_recipe_permission)
            visit current_path
            expect(page.has_link?('Dispensar')).to be true

            click_link 'Dispensar'
            expect(page).to have_content('Dispensar receta crónica:')
            expect(page).to have_content('Productos recetados')

            # Fail dispensation
            click_button 'Dispensar'
            expect(page).to have_content('Por favor revise los campos en el formulario')

            # Add a product to original product to dispense
            page.execute_script %Q{$("td:contains(#{@product.name})").first().closest('tr').find('a.add_fields').first().click()}

            # Select lot quantity
            page.execute_script %Q{$("td:contains(#{@product.name})").first().closest('tr').next('tr').find('button.select-lot-btn').first().click()}
            sleep 1
            expect(page).to have_content('Seleccionar lote en stock')
            page.execute_script %Q{$("input[name='lot-quantity[0]']").val(1).click()}
            click_button 'Volver'
            sleep 1

            click_button 'Dispensar'
            # Detail page
            expect(page).to have_content('Viendo receta crónica Dispensada parcial')
            expect(page).to have_content('Productos recetados 1')
            expect(page).to have_content('Dispensaciones 1')
            expect(page).to have_content('Movimientos 2')
            expect(page.has_link?('Dispensar')).to be true
            expect(page.has_link?('.complete-treatment')).to be false

            click_link 'Dispensaciones'
            expect(page.has_link?('.return-dispensation-modal')).to be false
          end

            it 'RETURN' do
              PermissionUser.create(user: @user, sector: @user.sector, permission: @return_chronic_recipe_permission)
              visit current_path

              expect(page.has_link?('.return-dispensation-modal')).to be true
              find(:css, '.return-dispensation-modal').first.click
              sleep 1
              expect(page).to have_content('Retornar y eliminar dispensación con fecha')
              expect(page).to have_content('Se volverán a stock los siguientes productos:')
              expect(page).to have_content('Está seguro de que desea retornar?')
              expect(page.has_link?('Volver')).to be true
              expect(page.has_link?('Continuar')).to be true
              click_link 'Continuar'
              expect(page).to have_content('Dispensaciones 0')
            end
          sleep 5
        end
      end
    end

  end
end

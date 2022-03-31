require 'rails_helper'

RSpec.feature 'Permissions::ChronicPrescriptions', type: :feature do

  before(:all) do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Recetas Crónicas')
    @read_chronic_recipe_permission = create(:permission, name: 'read_chronic_prescriptions', permission_module: @permission_module)
    @create_chronic_recipe_permission = create(:permission, name: 'create_chronic_prescriptions', permission_module: @permission_module)
    @dispense_chronic_recipe_permission = create(:permission, name: 'dispense_chronic_prescriptions', permission_module: @permission_module)
    @return_chronic_recipe_permission = create(:permission, name: 'return_chronic_prescriptions', permission_module: @permission_module)
    @update_chronic_recipe_permission = create(:permission, name: 'update_chronic_prescriptions', permission_module: @permission_module)
    @complete_treatment_chronic_recipe_permission = create(:permission, name: 'complete_treatment_chronic_prescriptions', permission_module: @permission_module)
    @destroy_chronic_recipe_permission = create(:permission, name: 'destroy_chronic_prescriptions', permission_module: @permission_module)

    # Create scenario with professional form completed
    @professionals_permission_module = create(:permission_module, name: 'Profesionales')
    @create_professional_permission = create(:permission, name: 'create_professionals', permission_module: @professionals_permission_module)
    PermissionUser.create(user: @user, sector: @user.sector, permission: @create_professional_permission)
    @product = create(:unidad_product)
    @product_1 = create(:product_1)
    lot = create(:province_lot_without_product, product: @product)
    lot_1 = create(:province_lot_without_product_1, code: 'BB-12', product: @product_1)
    stock = create(:stock, product: @product, sector: @user.sector)
    stock_1 = create(:stock, product: @product_1, sector: @user.sector)
    LotStock.create(quantity: 1500, lot: lot, stock: stock)
    LotStock.create(quantity: 1500, lot: lot_1, stock: stock_1)
  end

  background do
    sign_in_as(@user)
  end

  describe 'Chronic Recipes ::', js: true do
    subject { page }

    it 'does not show "Recetas" link' do
      visit '/'
      expect(page).to_not have_selector(:css, "a[href='#{prescriptions_path}']")
    end

    describe 'Add permissions ::' do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_chronic_recipe_permission)
      end

      it 'can READ' do
        visit '/'
        expect(page).to have_selector(:css, "a[href='#{prescriptions_path}']")
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
            expect(page.has_css?('.return-dispensation-modal')).to be false
            # Return
            PermissionUser.create(user: @user, sector: @user.sector, permission: @return_chronic_recipe_permission)
            visit current_path
            click_link 'Dispensaciones'
            expect(page.has_css?('.return-dispensation-modal')).to be true
            first('.return-dispensation-modal').click
            sleep 1
            expect(page).to have_content('Retornar y eliminar dispensación con fecha')
            expect(page).to have_content('Se volverán a stock los siguientes productos:')
            expect(page).to have_content('Está seguro de que desea retornar?')
            expect(page.has_link?('Volver')).to be true
            expect(page.has_link?('Continuar')).to be true
            click_link 'Continuar'
            expect(page).to have_content('Dispensaciones 0')
            # Edit
            expect(page.has_link?('Editar')).to be false
            PermissionUser.create(user: @user, sector: @user.sector, permission: @update_chronic_recipe_permission)
            visit current_path
            expect(page.has_link?('Editar')).to be true
            click_link 'Editar'
            expect(page).to have_content('Editando receta crónica')
            click_link 'Agregar insumo'
            # Add other product and with dispense permission
            add_original_product_by_code('1717', 10)
            click_button 'Guardar'
            expect(page).to have_content('Dispensar receta crónica')
            click_link 'Volver'
            # List filters
            expect(page.has_css?('#filterrific_filter')).to be true
            expect(page.has_css?('input[name="filterrific[search_by_remit_code]"]')).to be true
            expect(page.has_css?('input[name="filterrific[search_by_professional]"]')).to be true
            expect(page.has_css?('input[name="filterrific[search_by_patient]"]')).to be true
            expect(page.has_css?('input[name="filterrific[date_prescribed_since]"]')).to be true
            expect(page.has_css?('select[name="filterrific[for_statuses][]"]', visible: false)).to be true
            expect(page.has_css?('select[name="filterrific[sorted_by]"]', visible: false)).to be true
            # List
            expect(page.has_css?('#filterrific_results')).to be true
            expect(page.has_css?('#chronic_prescriptions')).to be true
            within '#chronic_prescriptions' do
              expect(page.has_css?('a > svg.fa-paper-plane', count: 1)).to be true
              expect(page.has_css?('a > svg.fa-eye', count: 1)).to be true
              expect(page.has_css?('a > svg.fa-pen', count: 1)).to be true
              expect(page.has_css?('a > svg.fa-trash', count: 1)).to be false
              find('a > svg.fa-eye').ancestor('a').click
            end
            # Finish treatment
            expect(page).to have_content('Viendo receta crónica')
            expect(page.has_css?('#supplies')).to be true
            within '#supplies' do
              within first('tr') do
                expect(page.has_css?('a.btn-warning > svg.fa-check', count: 1)).to be false
              end
            end
            PermissionUser.create(user: @user, sector: @user.sector, permission: @complete_treatment_chronic_recipe_permission)
            visit current_path
            within '#supplies' do
              expect(page.has_css?('a.btn-warning > svg.fa-check', count: 2)).to be true
              first('a.btn-warning > svg.fa-check').ancestor('a').click
              sleep 1
            end
            expect(page).to have_content('Terminar tratamiento')
            expect(page).to have_content('Terminado por el médico')
            expect(page).to have_content('Observaciones')
            expect(page.has_button?('Volver')).to be true
            expect(page.has_button?('Aceptar')).to be true
            click_button 'Aceptar'
            expect(page).to have_content('Observaciones no puede estar en blanco')

            within first('.edit_original_chronic_prescription_product') do
              fill_in 'original_chronic_prescription_product_finished_observation', with: 'Has a good recovery and no longer requires the medication'
            end
            click_button 'Aceptar'
            sleep 1
            within '#supplies' do
              expect(page.has_css?('a.btn-warning > svg.fa-check', count: 1)).to be true
              expect(page).to have_content('Terminado manual')
            end
            # Destroy
            click_link 'Volver'
            PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_chronic_recipe_permission)
            visit current_path
            expect(page.has_css?('#chronic_prescriptions')).to be true
            within '#chronic_prescriptions' do
              within first('tr') do
                expect(page.has_css?('button > svg.fa-trash', count: 1)).to be true
              end
              first('tr').find('button > svg.fa-trash').ancestor('button').click
              sleep 1
            end
            expect(page).to have_content('Eliminar prescripción')
            expect(page.has_button?('Volver')).to be true
            expect(page.has_link?('Confirmar')).to be true

            click_link 'Confirmar'
            sleep 1
            expect(page.has_css?('#chronic_prescriptions')).to be true
            within '#chronic_prescriptions' do
              expect(page.has_css?('tr')).to be false
            end

          end
          sleep 5
        end
      end
    end
  end
end

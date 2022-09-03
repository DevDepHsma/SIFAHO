require 'rails_helper'

RSpec.feature 'Permissions::ChronicPrescriptions', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Crónicas')
    @read_chronic_recipe_permission = permission_module.permissions.find_by(name: 'read_chronic_prescriptions')
    @create_chronic_recipe_permission = permission_module.permissions.find_by(name: 'create_chronic_prescriptions')
    @dispense_chronic_recipe_permission = permission_module.permissions.find_by(name: 'dispense_chronic_prescriptions')
    @return_chronic_recipe_permission = permission_module.permissions.find_by(name: 'return_chronic_prescriptions')
    @update_chronic_recipe_permission = permission_module.permissions.find_by(name: 'update_chronic_prescriptions')
    @complete_treatment_chronic_recipe_permission = permission_module.permissions.find_by(name: 'complete_treatment_chronic_prescriptions')
    @destroy_chronic_recipe_permission = permission_module.permissions.find_by(name: 'destroy_chronic_prescriptions')
    patient_permission_module = PermissionModule.includes(:permissions).find_by(name: 'Pacientes')
    @create_patient_permission = patient_permission_module.permissions.find_by(name: 'create_patients')

    # Create scenario with professional form completed
    professionals_permission_module = PermissionModule.includes(:permissions).find_by(name: 'Profesionales')
    @create_professional_permission = professionals_permission_module.permissions.find_by(name: 'create_professionals')
    @read_professional_permission = professionals_permission_module.permissions.find_by(name: 'read_professionals')
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @create_professional_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_professional_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector, permission: @create_patient_permission)
  end

  background do
    sign_in_as(@farm_provider)
  end

  describe 'Chronic Recipes ::', js: true do
    subject { page }

    it 'does not show "Recetas" link' do
      visit '/'
      expect(page).to_not have_selector(:css, "a[href='#{prescriptions_path}']")
    end

    describe 'Add permissions ::' do
      before(:each) do
        PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                              permission: @read_chronic_recipe_permission)
      end

      it 'can READ' do
        visit '/'
        expect(page).to have_selector(:css, "a[href='#{prescriptions_path}']")
      end

      describe '' do
        it 'CRUD' do
          expect(page.has_css?('#new-chronic')).to be false
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @create_chronic_recipe_permission)

          5.times do |_prescription|
            patient = @patients.sample
            qualification = @qualifications.sample
            find_or_create_patient_by_dni('Crónicas', patient.dni, 'Crónica')
            expect(page.has_css?('#new-chronic')).to be true
            find_or_create_professional_by_enrollment(qualification)
            # Add product
            add_original_product_to_recipe(rand(1..3), 1)
            click_button 'Guardar'
            expect(page).to have_content('Viendo receta crónica')
            expect(page.has_link?('Volver')).to be true
            expect(page.has_link?('Dispensar')).to be false
          end
          # Create a dispense
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @dispense_chronic_recipe_permission)
          visit current_path
          expect(page.has_link?('Dispensar')).to be true

          click_link 'Dispensar'
          sleep 1
          expect(page).to have_content('Dispensar receta crónica:')
          expect(page).to have_content('Productos recetados')

          # Fail dispensation
          click_button 'Dispensar'
          expect(page).to have_content('Por favor revise los campos en el formulario')

          # Add a product to original product to dispense
          page.execute_script %{$('a.add_fields').first().click()}

          # Select lot quantity
          page.execute_script %{$('button.select-lot-btn').first().click()}
          sleep 1
          expect(page).to have_content('Seleccionar lote en stock')
          page.execute_script %{$("input[name='lot-quantity[0]']").val(1).click()}
          click_button 'Volver'
          sleep 1
          click_button 'Dispensar'
          # Detail page
          expect(page).to have_content('Viendo receta crónica Dispensada parcial')
          expect(page).to have_content('Productos recetados')
          expect(page).to have_content('Dispensaciones 1')
          expect(page).to have_content('Movimientos 2')
          expect(page.has_link?('Dispensar')).to be true
          expect(page.has_link?('.complete-treatment')).to be false
          click_link 'Dispensaciones'
          expect(page.has_css?('.return-dispensation-modal')).to be false
          # Return
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @return_chronic_recipe_permission)
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
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @update_chronic_recipe_permission)
          visit current_path
          expect(page.has_link?('Editar')).to be true
          click_link 'Editar'
          expect(page).to have_content('Editando receta crónica')
          click_link 'Agregar producto'
          add_original_product_to_recipe(rand(1..3), 10)
          click_button 'Guardar'
          sleep 1
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
            expect(page.has_css?('a > svg.fa-paper-plane')).to be true
            expect(page.has_css?('a > svg.fa-eye')).to be true
            expect(page.has_css?('a > svg.fa-pen')).to be true
            expect(page.has_css?('a > svg.fa-trash')).to be false
            first('a > svg.fa-eye').ancestor('a').click
          end
          # Finish treatment
          expect(page).to have_content('Viendo receta crónica')
          expect(page.has_css?('#supplies')).to be true
          within '#supplies' do
            within first('tr') do
              expect(page.has_css?('a.btn-warning > svg.fa-check')).to be false
            end
          end
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @complete_treatment_chronic_recipe_permission)
          visit current_path
          within '#supplies' do
            expect(page.has_css?('a.btn-warning > svg.fa-check')).to be true
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
            fill_in 'original_chronic_prescription_product_finished_observation',
                    with: 'Has a good recovery and no longer requires the medication'
          end
          click_button 'Aceptar'
          sleep 1
          within '#supplies' do
            expect(page.has_css?('a.btn-warning > svg.fa-check')).to be true
            expect(page).to have_content('Terminado manual')
          end
          click_link 'Volver'
          # Destroy: chronic list
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @destroy_chronic_recipe_permission)
          visit current_path
          expect(page.has_css?('#chronic_prescriptions')).to be true
          within '#chronic_prescriptions' do
            within first('tr') do
              expect(page.has_css?('button.delete-item')).to be true
            end
            first('button.delete-item').click
            sleep 1
          end
          expect(page).to have_content('Eliminar prescripción')
          expect(page.has_button?('Volver')).to be true
          expect(page.has_link?('Confirmar')).to be true

          click_link 'Confirmar'
          sleep 1
          expect(page.has_css?('#chronic_prescriptions')).to be true

          # Destroy with js render: on main recipe page
          patient = @patients.sample
          visit '/recetas'
          within '#new_patient' do
            page.execute_script %{$('#patient-dni').focus().val("#{patient.dni}").keydown()}
          end
          sleep 1
          page.execute_script("$('.ui-menu-item:contains(#{patient.dni})').first().click()")
          within '#container-receipts-list' do
            expect(page).to have_content('Recetas')
            expect(page).to have_selector('#chronic-prescriptions')
            expect(page).to have_selector('button.delete-item')
            page.execute_script %{$('button.delete-item').first().click()}
          end
          sleep 1
          expect(page).to have_content('Eliminar prescripción')
          expect(page).to have_selector('#delete-item')
          within '#delete-item' do
            expect(page.has_button?('Volver')).to be true
            expect(page.has_link?('Confirmar')).to be true
            click_button 'Volver'
          end
          sign_out_as(@farm_provider)
        end
      end
    end
  end
end

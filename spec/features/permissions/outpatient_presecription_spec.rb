require 'rails_helper'

RSpec.feature 'Permissions::OutpatientPrescriptions', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Ambulatorias')
    @read_outpatient_permission = permission_module.permissions.find_by(name: 'read_outpatient_recipes')
    @dispense_recipe_permission = permission_module.permissions.find_by(name: 'dispense_outpatient_recipes')
    @return_recipe_permission = permission_module.permissions.find_by(name: 'return_outpatient_recipes')
    @update_recipe_permission = permission_module.permissions.find_by(name: 'update_outpatient_recipes')
    @destroy_recipe_permission = permission_module.permissions.find_by(name: 'destroy_outpatient_recipes')

    patient_permission_module = PermissionModule.includes(:permissions).find_by(name: 'Pacientes')
    @create_patient_permission = patient_permission_module.permissions.find_by(name: 'create_patients')

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

  describe 'Outpatient Recipes ::', js: true do
    subject { page }

    it 'show "Recetas" link' do
      visit '/'
      expect(page).to_not have_selector(:css, "a[href='#{prescriptions_path}']")
    end

    describe 'Add permissions ::' do
      before(:each) do
        PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                              permission: @read_outpatient_permission)
      end

      it 'LIST' do
        visit '/'
        expect(page).to have_selector(:css, "a[href='#{prescriptions_path}']")
      end

      describe 'CREATE :' do
        it 'FAIL' do
          visit '/recetas'
          expect(page.has_css?('#new-outpatient')).to be false
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @dispense_recipe_permission)
          5.times do |_prescription|
            patient = @patients.sample
            qualification = @qualifications.sample
            find_or_create_patient_by_dni('Ambulatorias', patient.dni, 'Ambulatoria')
            find_or_create_professional_by_enrollment(qualification)
            expect(page).to have_content('Agregar receta ambulatoria')
            expect(page).to have_content(patient.dni)
            expect(page.has_css?('input#professional')).to be true
            expect(page.has_css?('input#outpatient_prescription_date_prescribed')).to be true
            expect(page.has_css?('textarea#outpatient_prescription_observation')).to be true
            expect(page.has_css?('#order-product-cocoon-container')).to be true
            expect(page.has_field?('Código', type: 'text')).to be true
            expect(page.has_field?('Nombre', type: 'text')).to be true
            expect(page.has_css?('input#outpatient_prescription_outpatient_prescription_products_attributes_0_request_quantity')).to be true
            expect(page.has_css?('input#outpatient_prescription_outpatient_prescription_products_attributes_0_delivery_quantity')).to be true
            expect(page.has_link?('Agregar producto')).to be true
            expect(page.has_button?('Dispensar')).to be true
            # Add product
            expect(page.has_css?('#professional')).to be true

            add_products_to_recipe(rand(1..2), rand(5..20), rand(5..20))
            # Dispense
            click_button 'Dispensar'
            expect(page).to have_content('Viendo receta ambulatoria')
            expect(page.has_link?('Volver')).to be true
            expect(page.has_link?('Imprimir')).to be true
            expect(page.has_button?('Retornar')).to be false
            expect(page.has_link?('Dispensar')).to be false
            expect(page.has_link?('Editar')).to be false
          end
          # Add return permission
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @return_recipe_permission)
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
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @update_recipe_permission)
          visit current_path
          expect(page.has_link?('Editar')).to be true
          click_link 'Editar'
          expect(page).to have_content('Editando receta ambulatoria')
          within '#order-product-cocoon-container' do
            page.execute_script %{$('input.request-quantity').first().val(50).keydown()}
            page.execute_script %{$('input.deliver-quantity').first().val(50).keydown()}
            page.execute_script %{$('button.select-lot-btn').first().click()}
            sleep 1
          end
          # Select a lot
          expect(page.has_css?('#table-lot-selection')).to be true
          within '#lot-selection' do
            page.execute_script %{$('input[name="lot-quantity[0]"]').click().val(50)}
            click_button 'Volver'
          end
          click_button 'Dispensar'
          expect(page).to have_content('Viendo receta ambulatoria')
          ## Destroy with js render
          PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                                permission: @destroy_recipe_permission)
          visit '/recetas'
          patient = @patients.sample
          qualification = @qualifications.sample
          find_or_create_patient_by_dni('Ambulatorias', patient.dni, 'Ambulatoria')
          expect(page.has_css?('#new-outpatient')).to be true
          find_or_create_professional_by_enrollment(qualification)
          # Add product
          expect(page.has_css?('#professional')).to be true
          @outpatient_product = @products.sample
          add_products_to_recipe(rand(1..2), rand(5..20), rand(5..20))
          click_button 'Dispensar'
          expect(page).to have_content('Viendo receta ambulatoria')
          click_button 'Retornar'
          sleep 1
          click_link 'Confirmar'
          sleep 1
          within '#dropdown-menu-header' do
            click_link 'Recetas'
          end
          within '#new_patient' do
            page.execute_script %{$('#patient-dni').focus().val("#{patient.dni}").keydown()}
          end
          sleep 1
          page.execute_script("$('.ui-menu-item:contains(#{patient.dni})').first().click()")
          sleep 10
          within '#container-receipts-list' do
            expect(page).to have_content('Recetas')
            expect(page).to have_selector('#outpatient-prescriptions')
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
          within '#dropdown-menu-header' do
            click_link 'Ambulatorias'
          end
          within '#outpatient-prescriptions-filter' do
            fill_in 'filter[patient_full_name]', with: patient.dni
            click_button 'Buscar'
          end
          sleep 1
          within '#table_results' do
            expect(page).to have_selector('button.delete-item')
            page.execute_script %{$('button.delete-item').first().click()}
          end
          expect(page).to have_content('Eliminar prescripción')
          expect(page).to have_selector('#delete-item')
          within '#delete-item' do
            expect(page.has_button?('Volver')).to be true
            expect(page.has_link?('Confirmar')).to be true
            click_button 'Volver'
          end
        end
      end
    end
  end
end

# == Test information

#  Testing modules:
#  Access permissions: List / Show /Create / Edit / Dispense
#  Present fields on create
#  Present fields and values on edit
#  Dispense a prescription
#  Validations on empty form
#  Check present field values on Dispense fails
#

require 'rails_helper'

RSpec.feature 'Permissions::ChronicPrescriptions', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Crónicas')
    @read_chronic_recipe_permission = permission_module.permissions.find_by(name: 'read_chronic_prescriptions')
    @create_chronic_recipe_permission = permission_module.permissions.find_by(name: 'create_chronic_prescriptions')
    @update_chronic_recipe_permission = permission_module.permissions.find_by(name: 'update_chronic_prescriptions')
    @complete_treatment_chronic_recipe_permission = permission_module.permissions.find_by(name: 'complete_treatment_chronic_prescriptions')

    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_chronic_recipe_permission)
    # Create scenario with professional form completed
    # professionals_permission_module = PermissionModule.includes(:permissions).find_by(name: 'Profesionales')
    # @create_professional_permission = professionals_permission_module.permissions.find_by(name: 'create_professionals')
    # @read_professional_permission = professionals_permission_module.permissions.find_by(name: 'read_professionals')
    # PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
    #                       permission: @create_professional_permission)
    # PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
    #                       permission: @read_professional_permission)
    # PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector, permission: @create_patient_permission)
  end

  background do
    sign_in_as(@farm_provider)
  end

  describe '', js: true do
    subject { page }

    describe 'Permission:' do
      it 'List' do
        visit '/'
        expect(page).to have_css('#sidebar-wrapper', visible: false)
        within '#sidebar-wrapper' do
          expect(page).to have_link('Recetas')
          click_link 'Recetas'
        end
        within '#dropdown-menu-header' do
          expect(page).to have_link('Crónicas')
          click_link 'Crónicas'
          sleep 10
        end
      end

      #     it 'Show' do
      #       visit '/recetas/ambulatorias'
      #       within '#outpatient_prescriptions' do
      #         expect(page).to have_css('.btn-detail')
      #       end
      #       outpatient_prescription = OutpatientPrescription.where(status: 'dispensada').sample
      #       visit "/recetas/ambulatorias/#{outpatient_prescription.id}"
      #       expect(page).to have_content('Viendo receta ambulatoria')
      #       expect(page).to have_content('Médico')
      #       expect(page).to have_content(outpatient_prescription.professional_fullname.titleize)
      #       expect(page).to have_content('Matrículas')
      #       expect(page).to have_content('Paciente')
      #       expect(page).to have_content(outpatient_prescription.patient_fullname.titleize)
      #       expect(page).to have_content('DNI')
      #       expect(page).to have_content(outpatient_prescription.patient_dni)
      #       expect(page).to have_content('Edad')
      #       expect(page).to have_content(outpatient_prescription.patient_age_string)
      #       expect(page).to have_content('Recetada')
      #       expect(page).to have_content(outpatient_prescription.date_prescribed.strftime('%d/%m/%Y'))
      #       expect(page).to have_content('Vencimiento')
      #       expect(page).to have_content(outpatient_prescription.expiry_date.strftime('%d/%m/%Y'))
      #       expect(page).to have_content('Código')
      #       expect(page).to have_content(outpatient_prescription.remit_code)
      #       expect(page).to have_content('Observaciones')
      #       expect(page).to have_content(outpatient_prescription.observation)
      #       expect(page).to have_link('Productos recetados')
      #       expect(page).to have_link('Movimientos')
      #       expect(page).to have_link('Volver')
      #       expect(page).to have_link('Imprimir')
      #     end

      #     it 'Create: form and fields' do
      #       visit '/recetas'
      #       patient = @patients.sample
      #       expect_patient_search_form
      #       find_and_fill_patient_attributes(patient.dni)
      #       within '#new-receipt-buttons' do
      #         expect(page).to have_link('Ambulatoria')
      #         click_link 'Ambulatoria'
      #       end

      #       expect(page).to have_content(patient.last_name)
      #       expect(page).to have_content(patient.first_name)
      #       within '#new_outpatient_prescription' do
      #         expect(page).to have_field('outpatient_prescription[professional]', type: 'text')
      #         expect(page).to have_link('add-professional-btn')
      #         expect(page).to have_field('outpatient_prescription[date_prescribed]', type: 'text',
      #                                                                                with: DateTime.now.strftime('%d/%m/%Y'))
      #         expect(page).to have_field('outpatient_prescription[expiry_date]', type: 'hidden',
      #                                                                            with: (DateTime.now + 1.month).strftime('%d/%m/%Y'))
      #         expect(page).to have_field('outpatient_prescription[observation]', type: 'textarea')

      #         within '#order-product-cocoon-container' do
      #           expect(page).to have_field('product_code_fake-', type: 'text')
      #           expect(page).to have_field('product_name_fake-', type: 'text')
      #           expect(page).to have_field(
      #             'outpatient_prescription[outpatient_prescription_products_attributes][0][supply_unity_fake]', type: 'text', disabled: true
      #           )
      #           expect(page).to have_field(
      #             'outpatient_prescription[outpatient_prescription_products_attributes][0][stock_fake]', type: 'text', disabled: true
      #           )
      #           expect(page).to have_field(
      #             'outpatient_prescription[outpatient_prescription_products_attributes][0][request_quantity]', type: 'number'
      #           )
      #           expect(page).to have_field(
      #             'outpatient_prescription[outpatient_prescription_products_attributes][0][delivery_quantity]', type: 'number'
      #           )
      #           expect(page).to have_selector('button', class: 'select-lot-btn')
      #           expect(page).to have_field(
      #             'outpatient_prescription[outpatient_prescription_products_attributes][0][observation]', type: 'textarea'
      #           )
      #           expect(page).to have_selector('a', class: 'remove_fields')
      #         end

      #         expect(page).to have_link('Agregar producto')
      #       end
      #       expect(page).to have_link('Cancelar')
      #       expect(page).to have_button('Dispensar')
      #     end

      #     it 'Edit: form and fields' do
      #       outpatient_prescription = OutpatientPrescription.where(status: 'pendiente').first
      #       visit "/recetas/ambulatorias/#{outpatient_prescription.id}/editar"

      #       expect(page).to have_content('Editando receta ambulatoria')
      #       expect(page).to have_content(outpatient_prescription.patient.last_name)
      #       expect(page).to have_content(outpatient_prescription.patient.first_name)

      #       within "#edit_outpatient_prescription_#{outpatient_prescription.id}" do
      #         expect(page).to have_field('outpatient_prescription[professional]', type: 'text',
      #                                                                             with: outpatient_prescription.professional.full_info)
      #         expect(page).to have_field('outpatient_prescription[date_prescribed]', type: 'text',
      #                                                                                with: outpatient_prescription.date_prescribed.strftime('%d/%m/%Y'))
      #         expect(page).to have_field('outpatient_prescription[expiry_date]', type: 'hidden',
      #                                                                            with: outpatient_prescription.expiry_date.strftime('%d/%m/%Y'))
      #         expect(page).to have_field('outpatient_prescription[observation]', type: 'textarea',
      #                                                                            with: outpatient_prescription.observation)

      #         within '#order-product-cocoon-container' do
      #           outpatient_prescription.outpatient_prescription_products.each_with_index do |op, index|
      #             expect(page).to have_field("product_code_fake-#{op.id}", type: 'text', with: op.product.code)
      #             expect(page).to have_field("product_name_fake-#{op.id}", type: 'text', with: op.product.name)
      #             expect(page).to have_field(
      #               "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][supply_unity_fake]", type: 'text', disabled: true, with: op.product.unity.name
      #             )
      #             expect(page).to have_field(
      #               "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][stock_fake]", type: 'text', disabled: true, with: @farm_provider.sector.stock_to(op.product)
      #             )
      #             expect(page).to have_field(
      #               "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][request_quantity]", type: 'number', with: op.request_quantity
      #             )
      #             expect(page).to have_field(
      #               "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][delivery_quantity]", type: 'number', with: op.delivery_quantity
      #             )
      #             expect(page).to have_selector('button', class: 'select-lot-btn')
      #             expect(page).to have_field(
      #               "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][observation]", type: 'textarea', with: op.observation
      #             )
      #           end
      #         end
      #       end
      #       expect(page).to have_link('Cancelar')
      #       expect(page).to have_button('Dispensar')
      #     end
    end
  end

  # describe 'Chronic Recipes ::', js: true do
  #   subject { page }

  #   it 'does not show "Recetas" link' do
  #     visit '/'
  #     expect(page).to_not have_selector(:css, "a[href='#{prescriptions_path}']")
  #   end

  #   describe 'Add permissions ::' do
  #   before(:each) do
  #     PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
  #                           permission: @read_chronic_recipe_permission)
  #   end

  #   it 'can READ' do
  #     visit '/'
  #     expect(page).to have_selector(:css, "a[href='#{prescriptions_path}']")
  #   end

  #   describe '' do
  #     it 'CRUD' do
  #       expect(page.has_css?('#new-chronic')).to be false
  #       PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
  #                             permission: @create_chronic_recipe_permission)

  #       10.times do |_prescription|
  #         patient = @patients.sample
  #         qualification = @qualifications.sample
  #         find_or_create_patient_by_dni('Crónicas', patient.dni, 'Crónica')
  #         expect(page.has_css?('#new-chronic')).to be true
  #         find_or_create_professional_by_enrollment(qualification)
  #         # Add product
  #         add_original_product_to_recipe(rand(5..8), 1)
  #         click_button 'Guardar'
  #         expect(page).to have_content('Viendo receta crónica')
  #         expect(page.has_link?('Volver')).to be true
  #         expect(page.has_link?('Dispensar')).to be false
  #       end
  #       # Create a dispense
  #       PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
  #                             permission: @dispense_chronic_recipe_permission)
  #       visit current_path
  #       expect(page.has_link?('Dispensar')).to be true

  #       click_link 'Dispensar'
  #       sleep 1
  #       expect(page).to have_content('Dispensar receta crónica:')
  #       expect(page).to have_content('Productos recetados')

  #       # Fail dispensation
  #       click_button 'Dispensar'
  #       expect(page).to have_content('Por favor revise los campos en el formulario')

  #       # Add a product to original product to dispense
  #       page.execute_script %{$('a.add_fields').first().click()}

  #       # Select lot quantity
  #       page.execute_script %{$('button.select-lot-btn').first().click()}
  #       sleep 1
  #       expect(page).to have_content('Seleccionar lote en stock')
  #       page.execute_script %{$("input[name='lot-quantity[0]']").val(1).click()}
  #       click_button 'Volver'
  #       sleep 1
  #       click_button 'Dispensar'
  #       # Detail page
  #       expect(page).to have_content('Viendo receta crónica Dispensada parcial')
  #       expect(page).to have_content('Productos recetados')
  #       expect(page).to have_content('Dispensaciones 1')
  #       expect(page).to have_content('Movimientos 2')
  #       expect(page.has_link?('Dispensar')).to be true
  #       expect(page.has_link?('.complete-treatment')).to be false
  #       click_link 'Dispensaciones'
  #       expect(page.has_css?('.return-dispensation-modal')).to be false
  #       # Return
  #       PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
  #                             permission: @return_chronic_recipe_permission)
  #       visit current_path
  #       click_link 'Dispensaciones'
  #       expect(page.has_css?('.return-dispensation-modal')).to be true
  #       first('.return-dispensation-modal').click
  #       sleep 1
  #       expect(page).to have_content('Retornar y eliminar dispensación con fecha')
  #       expect(page).to have_content('Se volverán a stock los siguientes productos:')
  #       expect(page).to have_content('Está seguro de que desea retornar?')
  #       expect(page.has_link?('Volver')).to be true
  #       expect(page.has_link?('Continuar')).to be true
  #       click_link 'Continuar'
  #       expect(page).to have_content('Dispensaciones 0')
  #       # Edit
  #       expect(page.has_link?('Editar')).to be false
  #       PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
  #                             permission: @update_chronic_recipe_permission)
  #       visit current_path
  #       expect(page.has_link?('Editar')).to be true
  #       click_link 'Editar'
  #       expect(page).to have_content('Editando receta crónica')
  #       click_link 'Agregar producto'
  #       add_original_product_to_recipe(rand(1..3), 10)
  #       click_button 'Guardar'
  #       sleep 1
  #       expect(page).to have_content('Dispensar receta crónica')
  #       click_link 'Volver'
  #       # List filters
  #       expect(page.has_css?('#chronic-prescriptions-filter')).to be true
  #       expect(page.has_css?('input[name="filter[code]"]')).to be true
  #       expect(page.has_css?('input[name="filter[professional_full_name]"]')).to be true
  #       expect(page.has_css?('input[name="filter[patient_full_name]"]')).to be true
  #       expect(page.has_css?('input[name="filter[date_prescribed_since]"]')).to be true
  #       expect(page.has_css?('input[name="filter[date_prescribed_to]"]')).to be true
  #       expect(page.has_css?('select[name="filter[status]"]')).to be true
  #       expect(page.has_css?('input[name="filter[sort]"]', visible: false)).to be true
  #       # List
  #       expect(page.has_css?('#table_results')).to be true
  #       expect(page.has_css?('#chronic_prescriptions')).to be true
  #       within '#chronic_prescriptions' do
  #         expect(page.has_css?('a > svg.fa-paper-plane')).to be true
  #         expect(page.has_css?('a > svg.fa-eye')).to be true
  #         expect(page.has_css?('a > svg.fa-pen')).to be true
  #         expect(page.has_css?('a > svg.fa-trash')).to be false
  #         first('a > svg.fa-eye').ancestor('a').click
  #       end
  #       # Finish treatment
  #       expect(page).to have_content('Viendo receta crónica')
  #       expect(page.has_css?('#supplies')).to be true
  #       within '#supplies' do
  #         within first('tr') do
  #           expect(page.has_css?('a.btn-warning > svg.fa-check')).to be false
  #         end
  #       end
  #       PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
  #                             permission: @complete_treatment_chronic_recipe_permission)
  #       visit current_path
  #       within '#supplies' do
  #         expect(page.has_css?('a.btn-warning > svg.fa-check')).to be true
  #         first('a.btn-warning > svg.fa-check').ancestor('a').click
  #         sleep 1
  #       end
  #       expect(page).to have_content('Terminar tratamiento')
  #       expect(page).to have_content('Terminado por el médico')
  #       expect(page).to have_content('Observaciones')
  #       expect(page.has_button?('Volver')).to be true
  #       expect(page.has_button?('Aceptar')).to be true
  #       click_button 'Aceptar'
  #       expect(page).to have_content('Observaciones no puede estar en blanco')

  #       within first('.edit_original_chronic_prescription_product') do
  #         fill_in 'original_chronic_prescription_product_finished_observation',
  #                 with: 'Has a good recovery and no longer requires the medication'
  #       end
  #       click_button 'Aceptar'
  #       sleep 1
  #       within '#supplies' do
  #         expect(page.has_css?('a.btn-warning > svg.fa-check')).to be true
  #         expect(page).to have_content('Terminado manual')
  #       end
  #       click_link 'Volver'
  #       # Destroy: chronic list
  #       PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
  #                             permission: @destroy_chronic_recipe_permission)
  #       visit current_path
  #       expect(page.has_css?('#chronic_prescriptions')).to be true
  #       within '#chronic_prescriptions' do
  #         within first('tr') do
  #           expect(page.has_css?('button.delete-item')).to be true
  #         end
  #         first('button.delete-item').click
  #         sleep 1
  #       end
  #       expect(page).to have_content('Eliminar prescripción')
  #       expect(page.has_button?('Volver')).to be true
  #       expect(page.has_link?('Confirmar')).to be true

  #       click_link 'Confirmar'
  #       sleep 1
  #       expect(page.has_css?('#chronic_prescriptions')).to be true

  #       # Destroy with js render: on main recipe page
  #       # Before add a receipt
  #       patient = @patients.sample
  #       qualification = @qualifications.sample
  #       find_or_create_patient_by_dni('Crónicas', patient.dni, 'Crónica')
  #       expect(page.has_css?('#new-chronic')).to be true
  #       find_or_create_professional_by_enrollment(qualification)
  #       # Add product
  #       add_original_product_to_recipe(rand(1..3), 1)
  #       click_button 'Guardar'
  #       visit '/recetas'
  #       within '#new_patient' do
  #         page.execute_script %{$('#patient-dni').focus().val("#{patient.dni}").keydown()}
  #       end
  #       sleep 1
  #       page.execute_script("$('.ui-menu-item:contains(#{patient.dni})').first().click()")
  #       within '#container-receipts-list' do
  #         expect(page).to have_content('Recetas')
  #         expect(page).to have_selector('#chronic-prescriptions')
  #         expect(page).to have_selector('button.delete-item')
  #         page.execute_script %{$('button.delete-item').first().click()}
  #       end
  #       sleep 1
  #       expect(page).to have_content('Eliminar prescripción')
  #       expect(page).to have_selector('#delete-item')
  #       within '#delete-item' do
  #         expect(page.has_button?('Volver')).to be true
  #         expect(page.has_link?('Confirmar')).to be true
  #         click_button 'Volver'
  #       end
  #       sign_out_as(@farm_provider)
  #     end
  #   end
  # end
  # end
end

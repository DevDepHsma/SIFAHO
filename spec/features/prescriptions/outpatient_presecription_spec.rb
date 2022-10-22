#  Test information

#  Testing modules:
#  Access permissions: List / Show /Create / Edit / Dispense
#  Present fields on create
#  Present fields and values on edit
#  Dispense a prescription
#  Validations on empty form
#  Check present field values on Dispense fails
# 

require 'rails_helper'

RSpec.feature 'Permissions::OutpatientPrescriptions', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Ambulatorias')
    @read_outpatient_permission = permission_module.permissions.find_by(name: 'read_outpatient_recipes')
    @dispense_recipe_permission = permission_module.permissions.find_by(name: 'dispense_outpatient_recipes')
    @update_recipe_permission = permission_module.permissions.find_by(name: 'update_outpatient_recipes')

    patient_permission_module = PermissionModule.includes(:permissions).find_by(name: 'Pacientes')
    @create_patient_permission = patient_permission_module.permissions.find_by(name: 'create_patients')

    professionals_permission_module = PermissionModule.includes(:permissions).find_by(name: 'Profesionales')
    @create_professional_permission = professionals_permission_module.permissions.find_by(name: 'create_professionals')
    @read_professional_permission = professionals_permission_module.permissions.find_by(name: 'read_professionals')

    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_outpatient_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @dispense_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @update_recipe_permission)

    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @create_professional_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_professional_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector, permission: @create_patient_permission)
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
          expect(page).to have_link('Ambulatorias')
        end
      end

      it 'Show' do
        visit '/recetas/ambulatorias'
        within '#outpatient_prescriptions' do
          expect(page).to have_css('.btn-detail')
        end
        outpatient_prescription = OutpatientPrescription.where(status: 'dispensada').sample
        visit "/recetas/ambulatorias/#{outpatient_prescription.id}"
        expect(page).to have_content('Viendo receta ambulatoria')
        expect(page).to have_content('Médico')
        expect(page).to have_content(outpatient_prescription.professional_fullname.titleize)
        expect(page).to have_content('Matrículas')
        expect(page).to have_content('Paciente')
        expect(page).to have_content(outpatient_prescription.patient_fullname.titleize)
        expect(page).to have_content('DNI')
        expect(page).to have_content(outpatient_prescription.patient_dni)
        expect(page).to have_content('Edad')
        expect(page).to have_content(outpatient_prescription.patient_age_string)
        expect(page).to have_content('Recetada')
        expect(page).to have_content(outpatient_prescription.date_prescribed.strftime('%d/%m/%Y'))
        expect(page).to have_content('Vencimiento')
        expect(page).to have_content(outpatient_prescription.expiry_date.strftime('%d/%m/%Y'))
        expect(page).to have_content('Código')
        expect(page).to have_content(outpatient_prescription.remit_code)
        expect(page).to have_content('Observaciones')
        expect(page).to have_content(outpatient_prescription.observation)
        expect(page).to have_link('Productos recetados')
        expect(page).to have_link('Movimientos')
        expect(page).to have_link('Volver')
        expect(page).to have_link('Imprimir')
      end

      it 'Create: form and fields' do
        visit '/recetas'
        patient = @patients.sample
        expect_patient_search_form
        find_and_fill_patient_attributes(patient.dni)
        within '#new-receipt-buttons' do
          expect(page).to have_link('Ambulatoria')
          click_link 'Ambulatoria'
        end

        expect(page).to have_content(patient.last_name)
        expect(page).to have_content(patient.first_name)
        within '#new_outpatient_prescription' do
          expect(page).to have_field('outpatient_prescription[professional]', type: 'text')
          expect(page).to have_link('add-professional-btn')
          expect(page).to have_field('outpatient_prescription[date_prescribed]', type: 'text',
                                                                                 with: DateTime.now.strftime('%d/%m/%Y'))
          expect(page).to have_field('outpatient_prescription[expiry_date]', type: 'hidden',
                                                                             with: (DateTime.now + 1.month).strftime('%d/%m/%Y'))
          expect(page).to have_field('outpatient_prescription[observation]', type: 'textarea')

          within '#order-product-cocoon-container' do
            expect(page).to have_field('product_code_fake-', type: 'text')
            expect(page).to have_field('product_name_fake-', type: 'text')
            expect(page).to have_field(
              'outpatient_prescription[outpatient_prescription_products_attributes][0][supply_unity_fake]', type: 'text', disabled: true
            )
            expect(page).to have_field(
              'outpatient_prescription[outpatient_prescription_products_attributes][0][stock_fake]', type: 'text', disabled: true
            )
            expect(page).to have_field(
              'outpatient_prescription[outpatient_prescription_products_attributes][0][request_quantity]', type: 'number'
            )
            expect(page).to have_field(
              'outpatient_prescription[outpatient_prescription_products_attributes][0][delivery_quantity]', type: 'number'
            )
            expect(page).to have_selector('button', class: 'select-lot-btn')
            expect(page).to have_field(
              'outpatient_prescription[outpatient_prescription_products_attributes][0][observation]', type: 'textarea'
            )
            expect(page).to have_selector('a', class: 'remove_fields')
          end

          expect(page).to have_link('Agregar producto')
        end
        expect(page).to have_link('Cancelar')
        expect(page).to have_button('Dispensar')
      end

      it 'Edit: form and fields' do
        outpatient_prescription = OutpatientPrescription.where(status: 'pendiente').first
        visit "/recetas/ambulatorias/#{outpatient_prescription.id}/editar"

        expect(page).to have_content('Editando receta ambulatoria')
        expect(page).to have_content(outpatient_prescription.patient.last_name)
        expect(page).to have_content(outpatient_prescription.patient.first_name)

        within "#edit_outpatient_prescription_#{outpatient_prescription.id}" do
          expect(page).to have_field('outpatient_prescription[professional]', type: 'text',
                                                                              with: outpatient_prescription.professional.full_info)
          expect(page).to have_field('outpatient_prescription[date_prescribed]', type: 'text',
                                                                                 with: outpatient_prescription.date_prescribed.strftime('%d/%m/%Y'))
          expect(page).to have_field('outpatient_prescription[expiry_date]', type: 'hidden',
                                                                             with: outpatient_prescription.expiry_date.strftime('%d/%m/%Y'))
          expect(page).to have_field('outpatient_prescription[observation]', type: 'textarea',
                                                                             with: outpatient_prescription.observation)

          within '#order-product-cocoon-container' do
            outpatient_prescription.outpatient_prescription_products.each_with_index do |op, index|
              expect(page).to have_field("product_code_fake-#{op.id}", type: 'text', with: op.product.code)
              expect(page).to have_field("product_name_fake-#{op.id}", type: 'text', with: op.product.name)
              expect(page).to have_field(
                "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][supply_unity_fake]", type: 'text', disabled: true, with: op.product.unity.name
              )
              expect(page).to have_field(
                "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][stock_fake]", type: 'text', disabled: true, with: @farm_provider.sector.stock_to(op.product)
              )
              expect(page).to have_field(
                "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][request_quantity]", type: 'number', with: op.request_quantity
              )
              expect(page).to have_field(
                "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][delivery_quantity]", type: 'number', with: op.delivery_quantity
              )
              expect(page).to have_selector('button', class: 'select-lot-btn')
              expect(page).to have_field(
                "outpatient_prescription[outpatient_prescription_products_attributes][#{index}][observation]", type: 'textarea', with: op.observation
              )
            end
          end
        end
        expect(page).to have_link('Cancelar')
        expect(page).to have_button('Dispensar')
      end
    end

    describe 'Form' do
      before(:each) do
        visit '/recetas'
        patient = @patients.sample
        find_and_fill_patient_attributes(patient.dni)
        within '#new-receipt-buttons' do
          click_link 'Ambulatoria'
        end
      end

      # Require update products scope search
      # it 'dispense successfully' do
      #   10.times do |_prescription|
      #     visit '/recetas'
      #     patient = @patients.sample
      #     qualification = @qualifications.sample
      #     find_and_fill_patient_attributes(patient.dni) # Fill first patient form
      #     within '#new-receipt-buttons' do
      #       click_link 'Ambulatoria'
      #     end
      #     find_and_fill_professional_attribute(qualification) # Add professional
      #     add_products_to_recipe(rand(3..9), rand(5..20), rand(5..20)) # Add product
      #     click_button 'Dispensar'
      #     expect(page).to have_content('Viendo receta ambulatoria')
      #   end
      # end

      it 'dispense fail' do
        click_button 'Dispensar'
        within '#new_outpatient_prescription' do
          expect(page).to have_field('professional', class: 'is-invalid')
          expect(page).to have_selector('input#professional + .invalid-feedback', text: 'Profesional debe existir')

          expect(page).to have_field('product_code_fake-', type: 'text', class: 'is-invalid')
          expect(page).to have_selector('input[name="product_code_fake-"] + .invalid-feedback',
                                        text: 'Producto no puede estar en blanco')

          expect(page).to have_field('product_name_fake-', type: 'text', class: 'is-invalid')
          expect(page).to have_selector('input[name="product_name_fake-"] + .invalid-feedback',
                                        text: 'Producto no puede estar en blanco')

          expect(page).to have_field(
            'outpatient_prescription[outpatient_prescription_products_attributes][0][request_quantity]',
            type: 'number',
            class: 'is-invalid'
          )
          expect(page).to have_selector(
            'input[name="outpatient_prescription[outpatient_prescription_products_attributes][0][request_quantity]"] + .invalid-feedback',
            text: 'Solicitar no es un número'
          )
        end
      end

      it 'keep professional attribute' do
        qualification = @qualifications.sample
        professional = Professional.find(qualification.professional_id)
        find_and_fill_professional_attribute(qualification)
        click_button 'Dispensar'
        within '#new_outpatient_prescription' do
          expect(page).to have_field('professional', type: 'text', with: professional.full_info)
        end
      end

      it 'keep date_prescribed attribute' do
        a_date = (DateTime.now - 7.days).strftime('%d/%m/%Y')
        within '#new_outpatient_prescription' do
          fill_in 'outpatient_prescription[date_prescribed]', with: a_date
        end
        click_button 'Dispensar'
        within '#new_outpatient_prescription' do
          expect(page).to have_field('outpatient_prescription[date_prescribed]', type: 'text', with: a_date)
        end
      end

      it 'keep observation attribute' do
        within '#new_outpatient_prescription' do
          fill_in 'outpatient_prescription[observation]',
                  with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
        end
        click_button 'Dispensar'
        within '#new_outpatient_prescription' do
          expect(page).to have_field('outpatient_prescription[observation]', type: 'textarea',
                                                                             with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.')
        end
      end

      it 'keep products attributes' do
        product = @products.sample
        within '#order-product-cocoon-container' do
          page.execute_script %{$('input[name="product_name_fake-"]').last().val("#{product.name}").keydown()}
        end
        page.first('li.ui-menu-item', text: product.name).click
        click_button 'Dispensar'
        within '#order-product-cocoon-container' do
          expect(page).to have_field('product_code_fake-', type: 'text', with: product.code)
          expect(page).to have_field('product_name_fake-', type: 'text', with: product.name)
        end
      end

      it 'keep request_quantity attribute' do
        within '#order-product-cocoon-container' do
          fill_in 'outpatient_prescription[outpatient_prescription_products_attributes][0][request_quantity]', with: 10
        end
        click_button 'Dispensar'
        within '#order-product-cocoon-container' do
          expect(page).to have_field(
            'outpatient_prescription[outpatient_prescription_products_attributes][0][request_quantity]', type: 'number', with: 10
          )
        end
      end

      it 'keep delivery_quantity attributes' do
        product = @products.sample
        delivery_quantity = 5
        within '#order-product-cocoon-container' do
          page.execute_script %{$('input[name="product_name_fake-"]').last().val("#{product.name}").keydown()}
        end
        page.first('li.ui-menu-item', text: product.name).click

        within '#order-product-cocoon-container' do
          fill_in 'outpatient_prescription[outpatient_prescription_products_attributes][0][delivery_quantity]',
                  with: delivery_quantity
          page.first('button.select-lot-btn', text: 'Seleccionados 0').click
          sleep 1
        end

        within '#lot-selection' do
          fill_in 'lot-quantity[0]', with: delivery_quantity
          click_button 'Volver'
          sleep 1
        end
        click_button 'Dispensar'
        within '#order-product-cocoon-container' do
          expect(page).to have_field(
            'outpatient_prescription[outpatient_prescription_products_attributes][0][delivery_quantity]', type: 'number', with: delivery_quantity
          )
          expect(page).to have_button('Seleccionados 1')
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.feature 'Prescriptions::ChronicPrescriptions', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Crónicas')
    @read_chronic_recipe_permission = permission_module.permissions.find_by(name: 'read_chronic_prescriptions')
    @create_chronic_recipe_permission = permission_module.permissions.find_by(name: 'create_chronic_prescriptions')
    @update_chronic_recipe_permission = permission_module.permissions.find_by(name: 'update_chronic_prescriptions')
    @complete_treatment_chronic_recipe_permission = permission_module.permissions.find_by(name: 'complete_treatment_chronic_prescriptions')

    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_chronic_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @create_chronic_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @update_chronic_recipe_permission)

    professionals_permission_module = PermissionModule.includes(:permissions).find_by(name: 'Profesionales')
    @create_professional_permission = professionals_permission_module.permissions.find_by(name: 'create_professionals')
    @read_professional_permission = professionals_permission_module.permissions.find_by(name: 'read_professionals')

    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @create_professional_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_professional_permission)
  end

  background do
    sign_in @farm_provider
  end

  describe '', js: true do
    subject { page }

    describe 'Permission' do
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
        end
      end # list

      it 'Show' do
        visit '/recetas/cronicas'
        within '#chronic_prescriptions' do
          expect(page).to have_css('.btn-detail')
        end
        chronic_prescription = ChronicPrescription.where(status: 'dispensada').sample
        visit "/recetas/cronicas/#{chronic_prescription.id}"
        expect(page).to have_content('Viendo receta crónica Dispensada')
        expect(page).to have_content('Médico')
        expect(page).to have_content(chronic_prescription.professional_fullname.titleize)
        expect(page).to have_content('Matrículas')
        expect(page).to have_content('Paciente')
        expect(page).to have_content(chronic_prescription.patient_fullname.titleize)
        expect(page).to have_content('DNI')
        expect(page).to have_content(chronic_prescription.patient_dni)
        expect(page).to have_content('Edad')
        expect(page).to have_content(chronic_prescription.patient_age_string)
        expect(page).to have_content('Recetada')
        expect(page).to have_content(chronic_prescription.date_prescribed.strftime('%d/%m/%Y'))
        expect(page).to have_content('Vencimiento')
        expect(page).to have_content(chronic_prescription.expiry_date.strftime('%d/%m/%Y'))
        expect(page).to have_content('Código')
        expect(page).to have_content(chronic_prescription.remit_code)
        expect(page).to have_content('Observaciones')
        expect(page).to have_content(chronic_prescription.diagnostic)
        expect(page).to have_link('Productos recetados')
        expect(page).to have_link('Movimientos')
        expect(page).to have_link('Volver')
      end # show

      it 'Create: form and fields' do
        visit '/recetas'
        patient = @patients.sample
        expect_patient_search_form
        find_and_fill_patient_attributes(patient.dni)
        within '#new-receipt-buttons' do
          expect(page).to have_link('Crónica')
          click_link 'Crónica'
        end
        expect(page).to have_content(patient.last_name)
        expect(page).to have_content(patient.first_name)
        within '#new_chronic_prescription' do
          expect(page).to have_field('chronic_prescription[professional]', type: 'text')
          expect(page).to have_link('add-professional-btn')
          expect(page).to have_field('chronic_prescription[date_prescribed]', type: 'text',
                                                                              with: DateTime.now.strftime('%d/%m/%Y'))
          expect(page).to have_field('duration-treatment', type: 'text')
          expect(page).to have_field('chronic_prescription[expiry_date]', type: 'hidden',
                                                                          with: (DateTime.now + 6.month).strftime('%d/%m/%Y'))
          expect(page).to have_field('chronic_prescription[diagnostic]', type: 'textarea')

          within '#original-order-product-cocoon-container' do
            expect(page).to have_field('product_code_fake-', type: 'text')
            expect(page).to have_field('product_name_fake-', type: 'text')
            expect(page).to have_field(
              'chronic_prescription[original_chronic_prescription_products_attributes][0][supply_unity_fake]',
              type: 'text', disabled: true
            )
            expect(page).to have_field(
              'chronic_prescription[original_chronic_prescription_products_attributes][0][request_quantity]',
              type: 'number'
            )
            expect(page).to have_field(
              'chronic_prescription[original_chronic_prescription_products_attributes][0][total_request_quantity_fake]',
              type: 'text', disabled: true
            )
            expect(page).to have_field(
              'chronic_prescription[original_chronic_prescription_products_attributes][0][observation]',
              type: 'textarea'
            )
            expect(page).to have_selector('a', class: 'remove_fields')
          end

          expect(page).to have_link('Agregar producto')
        end # create form id
        expect(page).to have_link('Cancelar')
        expect(page).to have_button('Guardar')
      end # create

      it 'Edit: form and fields' do
        chronic_prescription = ChronicPrescription.where(status: 'pendiente').sample
        visit "/recetas/cronicas/#{chronic_prescription.id}/editar"

        expect(page).to have_content('Editando receta crónica')
        expect(page).to have_content(chronic_prescription.patient.last_name)
        expect(page).to have_content(chronic_prescription.patient.first_name)

        within "#edit_chronic_prescription_#{chronic_prescription.id}" do
          expect(page).to have_field('chronic_prescription[professional]', type: 'text',
                                                                           with: chronic_prescription.professional.full_info)
          expect(page).to have_field('chronic_prescription[date_prescribed]',
                                     type: 'text',
                                     with: chronic_prescription.date_prescribed.strftime('%d/%m/%Y'))
          expect(page).to have_field('chronic_prescription[expiry_date]',
                                     type: 'hidden',
                                     with: chronic_prescription.expiry_date.strftime('%d/%m/%Y'))
          expect(page).to have_field('chronic_prescription[diagnostic]',
                                     type: 'textarea',
                                     with: chronic_prescription.diagnostic)

          within '#original-order-product-cocoon-container' do
            chronic_prescription.original_chronic_prescription_products.each_with_index do |op, index|
              expect(page).to have_field("product_code_fake-#{op.id}", type: 'text', with: op.product.code)
              expect(page).to have_field("product_name_fake-#{op.id}", type: 'text', with: op.product.name)
              expect(page).to have_field(
                "chronic_prescription[original_chronic_prescription_products_attributes][#{index}][supply_unity_fake]",
                type: 'text',
                disabled: true,
                with: op.product.unity.name
              )
              expect(page).to have_field(
                "chronic_prescription[original_chronic_prescription_products_attributes][#{index}][request_quantity]",
                type: 'number',
                with: op.request_quantity
              )
              expect(page).to have_field(
                "chronic_prescription[original_chronic_prescription_products_attributes][#{index}][total_request_quantity_fake]",
                type: 'text',
                disabled: true,
                with: op.total_request_quantity
              )
              expect(page).to have_field(
                "chronic_prescription[original_chronic_prescription_products_attributes][#{index}][observation]",
                type: 'textarea',
                with: op.observation
              )
            end
          end
        end # edit form id
        expect(page).to have_link('Cancelar')
        expect(page).to have_button('Guardar')
      end # edit
    end # describe permissions

    describe 'Form' do
      before(:each) do
        visit '/recetas'
        @patient = @patients.sample
        find_and_fill_patient_attributes(@patient.dni)
        within '#new-receipt-buttons' do
          click_link 'Crónica'
        end
      end

      it 'create successfully' do
        10.times do
          qualification = @qualifications.sample
          find_and_fill_professional_attribute(qualification) # Add professional
          add_original_product_to_recipe(rand(2..4), rand(5..15)) # Add product
          click_button 'Guardar'
          expect(page).to have_content('Viendo receta crónica Pendiente')
          expect(page).to have_content("La receta crónica de #{@patient.fullname} se ha creado correctamente.")
          visit '/recetas'
          @patient = @patients.sample
          find_and_fill_patient_attributes(@patient.dni)
          within '#new-receipt-buttons' do
            click_link 'Crónica'
          end
        end
      end

      it 'create fail' do
        click_button 'Guardar'
        within '#new_chronic_prescription' do
          expect(page).to have_field('professional', class: 'is-invalid')
          expect(page).to have_selector('input#professional + .invalid-feedback', text: 'Profesional debe existir')

          expect(page).to have_field('product_code_fake-', type: 'text', class: 'is-invalid')
          expect(page).to have_selector('input[name="product_code_fake-"] + .invalid-feedback',
                                        text: 'Producto no puede estar en blanco')

          expect(page).to have_field('product_name_fake-', type: 'text', class: 'is-invalid')
          expect(page).to have_selector('input[name="product_name_fake-"] + .invalid-feedback',
                                        text: 'Producto no puede estar en blanco')

          expect(page).to have_field(
            'chronic_prescription[original_chronic_prescription_products_attributes][0][request_quantity]',
            type: 'number',
            class: 'is-invalid'
          )
          expect(page).to have_selector(
            'input[name="chronic_prescription[original_chronic_prescription_products_attributes][0][request_quantity]"] + .invalid-feedback',
            text: 'Dosis mensual no es un número'
          )
        end
      end

      it 'keep professional attribute' do
        qualification = @qualifications.sample
        professional = Professional.find(qualification.professional_id)
        find_and_fill_professional_attribute(qualification)
        click_button 'Guardar'
        within '#new_chronic_prescription' do
          expect(page).to have_field('chronic_prescription[professional]', type: 'text', with: professional.full_info)
        end
      end

      it 'keep date_prescribed attribute' do
        a_date = (DateTime.now - 7.days).strftime('%d/%m/%Y')
        within '#new_chronic_prescription' do
          fill_in 'chronic_prescription[date_prescribed]', with: a_date
        end
        click_button 'Guardar'
        within '#new_chronic_prescription' do
          expect(page).to have_field('chronic_prescription[date_prescribed]', type: 'text', with: a_date)
        end
      end

      it 'keep products attributes' do
        product = @products.sample
        within '#original-order-product-cocoon-container' do
          page.execute_script %{$('input[name="product_name_fake-"]').last().val("#{product.name}").keydown()}
        end
        page.first('li.ui-menu-item', text: product.name).click
        click_button 'Guardar'
        within '#original-order-product-cocoon-container' do
          expect(page).to have_field('product_code_fake-', type: 'text', with: product.code)
          expect(page).to have_field('product_name_fake-', type: 'text', with: product.name)
        end
      end

      it 'keep request_quantity and total_delivery_quantity attribute' do
        within '#original-order-product-cocoon-container' do
          fill_in 'chronic_prescription[original_chronic_prescription_products_attributes][0][request_quantity]',
                  with: 10
        end
        click_button 'Guardar'
        within '#original-order-product-cocoon-container' do
          expect(page).to have_field(
            'chronic_prescription[original_chronic_prescription_products_attributes][0][request_quantity]',
            type: 'number',
            with: 10
          )
          expect(page).to have_field(
            'chronic_prescription[original_chronic_prescription_products_attributes][0][total_request_quantity_fake]',
            type: 'text',
            with: 60,
            disabled: true
          )
        end
      end

      it 'keep observation attribute' do
        within '#original-order-product-cocoon-container' do
          fill_in 'chronic_prescription[original_chronic_prescription_products_attributes][0][observation]',
                  type: 'textarea',
                  with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut.'
        end
        click_button 'Guardar'
        within '#original-order-product-cocoon-container' do
          expect(page).to have_field(
            'chronic_prescription[original_chronic_prescription_products_attributes][0][observation]',
            type: 'textarea',
            with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut.'
          )
        end
      end

      it 'keep diagnostic attribute' do
        within '#new_chronic_prescription' do
          fill_in 'chronic_prescription[diagnostic]',
                  type: 'textarea',
                  with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
        end
        click_button 'Guardar'
        within '#new_chronic_prescription' do
          expect(page).to have_field('chronic_prescription[diagnostic]',
                                     type: 'textarea',
                                     with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.')
        end
      end
    end # describe form
  end # main describe
end

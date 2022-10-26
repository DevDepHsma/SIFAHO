module Helpers
  module Recipe
    def expect_patient_search_form
      within '#new_patient' do
        expect(page).to have_field('patient[dni]', type: 'text')
        expect(page).to have_field('patient[status]', type: 'hidden')
        expect(page).to have_field('patient[birthdate]', type: 'hidden')
        expect(page).to have_field('patient[marital_status]', type: 'hidden')
        expect(page).to have_field('patient[email]', type: 'hidden')
        expect(page).to have_field('patient[address][postal_code]', type: 'hidden')
        expect(page).to have_field('patient[address][line]', type: 'hidden')
        expect(page).to have_field('patient[address][city_name]', type: 'hidden')
        expect(page).to have_field('patient[address][state_name]', type: 'hidden')
        expect(page).to have_field('patient[address][country_name]', type: 'hidden')
        expect(page).to have_field('patient[andes_id]', type: 'hidden')
        expect(page).to have_field('patient[photo_andes_id]', type: 'hidden')
      end
      expect(page).to have_button('Guardar paciente', disabled: true)
    end

    def find_and_fill_patient_attributes(patient_dni)
      within '#new_patient' do
        page.execute_script %{$('input[name="patient[dni]"]').focus().val("#{patient_dni}").keydown()}
        sleep 2
      end
      expect(page.find('ul.ui-autocomplete')).to have_content(patient_dni.to_s)
      expect(page).to have_selector('li.ui-menu-item', text: patient_dni)
      page.first('li.ui-menu-item', text: patient_dni).click
      sleep 2
    end

    def find_and_fill_professional_attribute(qualification)
      expect(page).to have_field('professional')
      page.execute_script %{$("input#professional").val(#{qualification.code}).keydown()}
      sleep 1 
      expect(page.find('ul.ui-autocomplete')).to have_content(qualification.code.to_s)
      expect(page).to have_selector('li.ui-menu-item', text: qualification.code)
      page.first('li.ui-menu-item', text: qualification.code).click
      sleep 1
    end

    def add_products_to_recipe(product_size, product_req_quantity, product_del_quantity)
      products = @products.sample(product_size)
      products.each_with_index do |product, index|
        within '#order-product-cocoon-container' do
          page.execute_script %{$('input[name="product_name_fake-"]').last().val("#{product.name}").keydown()}
        end
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(product.name)
        page.execute_script("$('.ui-menu-item:contains(#{product.name})').first().click()")
        sleep 1
        within '#order-product-cocoon-container' do
          page.execute_script %{$('input.request-quantity').last().val("#{product_req_quantity}").keydown()}
          page.execute_script %{$('input.deliver-quantity').last().val("#{product_del_quantity}").keydown()}
          page.execute_script %{$('button.select-lot-btn').last().click()}
        end
        sleep 1
        # Select a lot
        expect(page.has_css?('#table-lot-selection')).to be true
        within '#lot-selection' do
          page.execute_script %{$('input[name="lot-quantity[0]"]').last().click().val("#{product_del_quantity}")}
          click_button 'Volver'
        end
        sleep 1
        click_link 'Agregar producto' unless (index + 1).eql?(product_size)
      end
    end

    def add_original_product_to_recipe(product_size, product_req_quantity)
      products = @products.sample(product_size)
      products.each_with_index do |product, index|
        within '#original-order-product-cocoon-container' do
          page.execute_script %{$('tr.nested-fields').last().find('input[name="product_name_fake-"]').last().val("#{product.name}").keydown()}
        end
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(product.name)
        page.execute_script("$('.ui-menu-item:contains(#{product.name})').first().click()")
        sleep 1
        within '#original-order-product-cocoon-container' do
          page.execute_script %{$('tr.nested-fields').last().find('input.request-quantity').first().val("#{product_req_quantity}").trigger('change')}
        end
        sleep 1
        click_link 'Agregar producto' unless (index + 1).eql?(product_size)
      end
    end
  end
end

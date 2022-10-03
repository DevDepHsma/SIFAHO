module Helpers
  module Recipe
    def find_or_create_patient_by_dni(link, patient_dni, type)
      visit '/'
      within '#sidebar-wrapper' do
        click_link 'Recetas'
      end
      expect(page.has_link?(link)).to be true
      within '#new_patient' do
        expect(page.has_css?('input#patient-dni')).to be true
        page.execute_script %{$('#patient-dni').focus().val("#{patient_dni}").keydown()}
        sleep 2
      end
      expect(find('ul.ui-autocomplete')).to have_content(patient_dni.to_s)
      page.execute_script("$('.ui-menu-item:contains(#{patient_dni})').first().click()")
      sleep 2
      if page.has_button?('Guardar paciente')
        find_button('Guardar paciente').click
      else
        within '#new-receipt-buttons' do
          click_link type
        end
      end
    end

    def find_or_create_professional_by_enrollment(qualification)
      expect(page.has_css?('input#professional')).to be true
      page.execute_script %{$("#professional").val(#{qualification.code}).keydown()}
      sleep 1
      expect(find('ul.ui-autocomplete')).to have_content(qualification.code.to_s)
      page.execute_script("$('.ui-menu-item:contains(#{qualification.code})').first().click()")
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

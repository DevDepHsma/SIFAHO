module Helpers
  module Recipe
    def find_or_create_patient_by_dni(link, patient_dni)
      visit '/'
      click_link 'Recetas'
      expect(page.has_link?(link)).to be true
      within '#new_patient' do
        expect(page.has_css?('input#patient-dni')).to be true
        page.execute_script %Q{$('#patient-dni').focus().val("#{patient_dni}").keydown()}
        sleep 2
      end
      expect(find('ul.ui-autocomplete')).to have_content("#{patient_dni}")
      page.execute_script("$('.ui-menu-item:contains(#{patient_dni})').first().click()")
      sleep 2
      find_button('Guardar paciente').click
    end

    def find_or_create_professional_by_enrollment(user, recipe_link_new, professional_ident)
      find(:css, recipe_link_new).click
      sleep 1
      expect(page.has_css?('#add-professional-btn')).to be true
      page.execute_script %Q{$('#add-professional-btn').click()}
      sleep 1
      within '#professional-form-async' do
        page.execute_script %Q{$('#last-name').focus().val("#{professional_ident}").keyup()}
        sleep 2
      end
      within '#professionals-list' do
        find('.btn-success', match: :first).click
      end
      sleep 2
    end

    def add_product_by_code(product_code, product_req_quantity, product_del_quantity)
      within '#order-product-cocoon-container' do
        page.execute_script %Q{$('input[name="product_code_fake-"]').val("#{product_code}").keydown()}
        sleep 2
      end
      expect(find('ul.ui-autocomplete')).to have_content("#{product_code}")
      page.execute_script("$('.ui-menu-item:contains(#{product_code})').first().click()")
      sleep 1
      within '#order-product-cocoon-container' do
        page.execute_script %Q{$('input.request-quantity').first().val("#{product_req_quantity}").keydown()}
        page.execute_script %Q{$('input.deliver-quantity').first().val("#{product_del_quantity}").keydown()}
        page.execute_script %Q{$('button.select-lot-btn').first().click()}
        sleep 1
      end
      # Select a lot
      expect(page.has_css?('#table-lot-selection')).to be true
      within '#lot-selection' do
        page.execute_script %Q{$('input[name="lot-quantity[0]"]').click().val("#{product_del_quantity}")}
        click_button 'Volver'
      end
      sleep 1
    end

    def add_original_product_by_code(product_code, product_req_quantity)
      within '#original-order-product-cocoon-container' do
        page.execute_script %Q{$('tr.nested-fields').last().find('input[name="product_code_fake-"]').last().val("#{product_code}").keydown()}
      end
      sleep 2
      expect(find('ul.ui-autocomplete')).to have_content("#{product_code}")
      page.execute_script("$('.ui-menu-item:contains(#{product_code})').first().click()")
      sleep 2
      within '#original-order-product-cocoon-container' do
        page.execute_script %Q{$('tr.nested-fields').last().find('input.request-quantity').first().val("#{product_req_quantity}").trigger('change')}
      end
      sleep 1
    end
  end
end
module Helpers
  module OrderTemplate
    def fill_order_template(**args)
      within args[:form_id] do
        fill_in (args[:template_name_input]).to_s, with: args[:template_name]
      end
      if args[:establishment_input]
        page.execute_script %{
          $("input##{args[:establishment_input]}").val("#{args[:sector].establishment.name}").keydown()
        }
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(args[:sector].establishment.name)
        page.execute_script("$('.ui-menu-item:contains(#{args[:sector].establishment.name})').first().click()")
      end
      sleep 1
      if args[:sector_input]
        expect(page.has_css?("select##{args[:sector_input]}", visible: false)).to be true
        page.execute_script %{$('select##{args[:sector_input]}').siblings('button').first().click()}
        expect(page.has_css?('ul.dropdown-menu')).to be true
        expect(page.has_css?('span', text: args[:sector].name)).to be true
        page.execute_script %{$('a>span.text:contains(#{args[:sector].name})').first().click()}
      end

      products = @products.sample(args[:products_size])
      products.each_with_index do |product, index|
        page.execute_script %{
          $('input.product-code').last().val("#{product.code}").keydown()
        }
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(product.code)
        page.execute_script("$('.ui-menu-item:contains(#{product.code})').first().click()")

        click_link 'Agregar producto' unless (index).eql?(args[:product_size])
        sleep 1
      end
    end
  end
end

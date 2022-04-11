module Helpers
  module Order
    def select_sector(sector_name, select_id)
      expect(page.has_css?(select_id.to_s, visible: false)).to be true
      page.execute_script %Q{$('#{select_id.to_s}').siblings('button').first().click()}
      expect(page.has_css?('ul.dropdown-menu')).to be true
      expect(page.has_css?('span', text: sector_name.to_s)).to be true
      page.execute_script %Q{$('a>span.text:contains(#{sector_name})').first().click()}
    end

    # products => array of products (should be persisted)
    # products_size => number of products that sample will rake
    #  **fields => filds that should been fill it
    def add_products(products, products_size, *fields_args)
      products.sample(products_size).each_with_index do |product, index|
        page.execute_script %Q{
          $($('input.product-code')[#{index}]).val("#{product[1]}").keydown()
        }
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(product[1].to_s)
        page.execute_script("$('.ui-menu-item:contains(#{product[1]})').first().click()")
        page.execute_script %Q{
          $($('input.request-quantity')[#{index}]).val(#{rand(100..750)}).keydown()
        }
        page.execute_script %Q{$('button.btn-save').first().click()}
        sleep 1
        click_link 'Agregar producto' unless (index + 1).eql?(products_size)
        sleep 1
      end
    end
  end
end
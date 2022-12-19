# encoding: UTF-8
module Helpers
  module Order
    def select_sector(sector_name, select_id, *establishment)
      sleep 1
      if establishment.count.positive?
        page.execute_script %{
          $('input#effector-establishment').val("#{establishment.first.name}").keydown()
        }
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(establishment.first.name)
        page.execute_script("$('.ui-menu-item:contains(#{establishment.first.name})').first().click()")
      end
      sleep 1
      page.find("#{select_id}", visible: false).sibling('button').click
      expect(page.has_css?('ul.dropdown-menu')).to be true
      expect(page.has_css?('span', text: sector_name.to_s)).to be true
      page.execute_script %{$('a>span.text:contains(#{sector_name})').first().click()}
    end

    # products => array of products (should be persisted)
    # products_size => number of products that sample will rake
    #  **fields => filds that should been fill it
    def add_products(product_size, **fields_args)
      products = @products.sample(product_size)
      products.each_with_index do |product, index|
        page.execute_script %{
          $('input.product-code').last().val("#{product.code}").keydown()
        }
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(product.code)
        page.execute_script("
          $('.ui-menu-item').filter(function(){ return $(this).text()==='#{product.code}';}).mouseover().click()
           ")
        if fields_args.include?(:request_quantity)
          page.execute_script %{
            $('input.request-quantity').last().val(#{rand(100..250)}).keydown()
          }
        end

        if fields_args.include?(:lot_code)
          page.execute_script %{
            $('input.receipt-product-lot-code').last().val('#{rand(100..250)}').keydown()
          }
        end

        if fields_args.include?(:laboratory)
          page.execute_script %{
            $('input.receipt-laboratory-name').last().val('ABBOTT LABORATORIES').keydown()
          }
          sleep 1
          expect(find('ul.ui-autocomplete')).to have_content('ABBOTT LABORATORIES ARGENTINA S.A.')
          page.execute_script("$('.ui-menu-item:contains(ABBOTT LABORATORIES ARGENTINA S.A.)').last().click()")
        end

        if fields_args.include?(:observations)
          # 74 characters
          page.execute_script %{
            $('textarea.observations').last().val('Lorem Ipsum is simply dummy text of the printing and typesetting industry.').keydown()
          }
        end
        page.execute_script %{$('button.btn-save').first().click()}
        if fields_args.include?(:select_lot_stock)
          expect(page).to have_content('Seleccionar lote en stock')
          expect(page).to have_content(product.name)
          expect(page).to have_content('Cantidad seleccionada')
          expect(page.has_button?('Volver')).to be true
          expect(page.has_button?('Guardar')).to be true
          expect(page).to have_content('Cantidad')
          expect(page).to have_content('Stock')
          expect(page).to have_content('Código')
          expect(page).to have_content('Estado')
          expect(page).to have_content('Procedencia')
          expect(page).to have_content('Vencimiento')
          expect(page).to have_content('Laboratorio')
          expect(page).to have_content('Reservado')
          expect(page.has_css?('#table-lot-selection')).to be true
          within '#table-lot-selection' do
            page.execute_script %{
              $($('input.quantity')[0]).val(#{rand(100..250)}).trigger('change')
            }
          end
          click_button 'Guardar'
          sleep 1
        end
        click_link 'Agregar producto' unless (index + 1).eql?(product_size)
        sleep 1
      end
    end

    def fill_products_deliver_quantity
      page.all(:css, 'a.btn-lot-selection').each do |btn|
        btn.click
        # page.execute_script %{$($('a.btn-lot-selection')[#{index}]).click()}
        expect(page).to have_content('Seleccionar lote en stock')
        expect(page).to have_content('Cantidad seleccionada')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        within '#table-lot-selection' do
          page.execute_script %{
            $($('input.quantity')[0]).val(#{rand(100..250)}).trigger('change')
          }
        end
        click_button 'Guardar'
        sleep 1
      end
    end
  end
end

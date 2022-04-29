module Helpers
  module Order
    def select_sector(sector_name, select_id, *establishment)

      if establishment.count.positive?
        page.execute_script %Q{
          $('input#effector-establishment').val("#{establishment.first.name}").keydown()
        }
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(establishment.first.name)
        page.execute_script("$('.ui-menu-item:contains(#{establishment.first.name})').first().click()")
      end
      expect(page.has_css?(select_id.to_s, visible: false)).to be true
      page.execute_script %Q{$('#{select_id.to_s}').siblings('button').first().click()}
      expect(page.has_css?('ul.dropdown-menu')).to be true
      expect(page.has_css?('span', text: sector_name.to_s)).to be true
      page.execute_script %Q{$('a>span.text:contains(#{sector_name})').first().click()}
    end

    # products => array of products (should be persisted)
    # products_size => number of products that sample will rake
    #  **fields => filds that should been fill it
    def add_products(products, **fields_args)
      products.each_with_index do |product, index|
        page.execute_script %Q{
          $($('input.product-code')[#{index}]).val("#{product[1]}").keydown()
        }
        sleep 1
        expect(find('ul.ui-autocomplete')).to have_content(product[1].to_s)
        page.execute_script("$('.ui-menu-item:contains(#{product[1]})').first().click()")
        if fields_args.include?(:request_quantity)
          page.execute_script %Q{
            $($('input.request-quantity')[#{index}]).val(#{rand(100..750)}).keydown()
          }
        end
        if fields_args.include?(:observations)
          # 74 characters
          page.execute_script %Q{
            $($('textarea.observations')[#{index}]).val('Lorem Ipsum is simply dummy text of the printing and typesetting industry.').keydown()
          }
        end
        page.execute_script %Q{$('button.btn-save').first().click()}
        sleep 1
        if fields_args.include?(:select_lot_stock)
          expect(page).to have_content('Seleccionar lote en stock')
          expect(page).to have_content(product[1].to_s)
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
            page.execute_script %Q{
              $($('input.quantity')[0]).val(#{rand(100..750)}).trigger('change')
            }
          end
          click_button 'Guardar'
          sleep 1
        end
        click_link 'Agregar producto' unless (index + 1).eql?(products.size)
        sleep 1
      end
    end

    def fill_products_deliver_quantity(products)
      products.each_with_index do |btn, index|
        page.execute_script %Q{$($('a.btn-lot-selection')[#{index}]).click()}
        expect(page).to have_content('Seleccionar lote en stock')
        expect(page).to have_content('Cantidad seleccionada')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        within '#table-lot-selection' do
          page.execute_script %Q{
            $($('input.quantity')[0]).val(#{rand(100..750)}).trigger('change')
          }
        end
        click_button 'Guardar'
        sleep 1
      end
    end
  end
end
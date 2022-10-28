# == Test Information

#  Testing modules:
#  Filter: fields and results
#  Pagination: presence and results
#  Sort: buttons and results
#  Destroy action
#

require 'rails_helper'

RSpec.feature 'ProductsFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Productos')
    @read_products = permission_module.permissions.find_by(name: 'read_products')
    @destroy_products = permission_module.permissions.find_by(name: 'destroy_products')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_products)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_products)
  end

  background do
    sign_in_as(@farm_applicant)
  end

  describe '', js: true do
    subject { page }

    before(:each) do
      visit '/productos'
    end

    describe 'form filters' do
      it 'has fields' do
        within '#products-filter' do
          expect(page).to have_field('filter[code]', type: 'text')
          expect(page).to have_field('filter[name]', type: 'text')
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button.btn-clean-filters')
        end
      end

      it 'by code' do
        products = Product.all.sample(5)
        products.each do |product|
          within '#products-filter' do
            fill_in 'filter[code]', with: product.code
            click_button 'Buscar'
            sleep 1
          end
          within '#products' do
            expect(page.first('tr').first('td')).to have_selector('mark.highlight-1', text: product.code)
          end
          within '#products-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by name' do
        products = Product.all.sample(5)
        products.each do |product|
          within '#products-filter' do
            fill_in 'filter[name]', with: product.name
            click_button 'Buscar'
            sleep 1
          end
          within '#products' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1', text: product.name)
          end
          within '#products-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
    end

    describe 'pagination' do
      before(:each) do
        @last_page = (Product.all.count / 15.to_f).ceil
      end

      it 'has pagination' do
        within '#paginate_footer nav' do
          expect(page).to have_selector('a.page-link', text: @last_page.to_s)
        end
      end

      it 'has pagination size selector' do
        within '#paginate_footer' do
          expect(page).to have_select('page-size-selection', with_options: %w[15 30 50 100])
        end
      end

      it 'change page number' do
        within '#paginate_footer nav' do
          expect(page).to have_selector('li.active', text: '1')
          click_link @last_page.to_s
          sleep 1
          expect(page).to have_selector('li.active', text: @last_page.to_s)
        end
      end

      it 'has 15 items per page by default' do
        within '#products' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#products' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Código')
          expect(page).to have_button('Nombre')
        end
      end

      it 'by code' do
        sorted_by_code_asc = Product.select(:code).order(code: :asc).first
        sorted_by_code_desc = Product.select(:code).order(code: :desc).first

        within '#table_results' do
          click_button 'Código'
          sleep 1
        end

        within '#products' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_asc.code)
        end

        within '#table_results' do
          click_button 'Código'
          sleep 1
        end

        within '#products' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_desc.code)
        end
      end

      it 'by name' do
        sorted_by_name_asc = Product.select(:name).order(name: :asc).first
        sorted_by_name_desc = Product.select(:name).order(name: :desc).first

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#products' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_name_asc.name)
        end

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#products' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_name_desc.name)
        end
      end
    end

    describe 'Destroy permission' do
      before(:each) do
        @product_to_del = @products_without_stock.sample
        within '#products-filter' do
          fill_in 'filter[name]', with: @product_to_del.name
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button destroy' do
        within '#products' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#products' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar producto')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'destroy items' do
        within '#products' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          click_link 'Confirmar'
          sleep 1
        end
        expect(page).to have_text("El suministro #{@product_to_del.name} se ha eliminado correctamente.")
      end
    end
  end
end

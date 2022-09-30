require 'rails_helper'

RSpec.feature 'ProductsFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Productos')
    @read_products = permission_module.permissions.find_by(name: 'read_products')
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }

    before(:each) do
      PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_products)
      visit '/'
    end

    after(:each) do
      sleep 1
      sign_out_as(@farm_applicant)
    end
    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
      within '#sidebar-wrapper' do
        expect(page.has_link?('Productos')).to be true
        click_link 'Productos'
      end
    end
    describe 'filter form' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Productos')).to be true
          click_link 'Productos'
        end
      end
      it 'displays filters form' do
        expect(page.has_css?('#products-filter')).to be true
      end
      it 'displays code input' do
        within '#products-filter' do
          expect(page.has_css?('input[name="filter[code]"]')).to be true
        end
      end

      it 'displays name input' do
        within '#products-filter' do
          expect(page.has_css?('input[name="filter[name]"]')).to be true
        end
      end
      it 'displays button "Buscar"' do
        within '#products-filter' do
          expect(page.has_button?('Buscar')).to be true
        end
      end
      it 'displays button limpiar' do
        within '#products-filter' do
          expect(page.has_css?('.btn-clean-filters')).to be true
        end
      end
    end

    describe 'form actions' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Productos')).to be true
          click_link 'Productos'
        end
      end
      it 'displays loader on click "Buscar"' do
        within '#products-filter' do
          click_button 'Buscar'

          # expect(page.has_css?("#loader-container")).to be true
        end
      end
      it 'displays loader on click "Buscar"' do
        within '#products-filter' do
          fill_in 'filter[code]', with: '101010'

          click_button 'Buscar'
          sleep 1
          # expect(page.has_css?("#loader-container")).to be true
        end

        within '#products' do
          expect(page.has_css?('tr', count: 1)).to be true
          sleep 2
        end
        within '#products-filter' do
          page.execute_script %{$("button.btn-clean-filters")[0].click()}
        end
        sleep 1
        within '#products-filter' do
          fill_in 'filter[name]', with: 'SOXUPRINA AMPOLLA'
          click_button 'Buscar'
          sleep 1
          # expect(page.has_css?("#loader-container")).to be true
        end
        within '#products' do
          expect(page.has_css?('tr', count: 1)).to be true
          sleep 1
          page.execute_script %{$("button.btn-clean-filters")[0].click()}
        end
      end
    end

    describe 'paginator actions' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Productos')).to be true
          click_link 'Productos'
        end
      end

      it 'change page' do
        sleep 1
        within '#paginate_footer nav' do
          # page.execute_script %{$(".page-item a")[0].click()}
          expect(page.has_css?('li.active', text: '1')).to be true
          click_link '2'
          sleep 1
          expect(page.has_css?('li.active', text: '2')).to be true
          # page.execute_script %{$(".page-item")[2].getAttribute('class').indexOf('active')!=-1}
        end
      end
      it 'checks pages count' do
        products_count = Product.all.count
        page_size = (products_count / 15.to_f).ceil
        within '#paginate_footer nav' do
          expect(page.has_link?(page_size.to_s)).to be true
          expect(page.has_link?((page_size + 1).to_s)).not_to be true
        end
      end

      it 'checks results count by page' do
        products_count = Product.all.count
        page_size = (products_count / 15.to_f).ceil
        within '#paginate_footer nav' do
          expect(page.has_link?(page_size.to_s)).to be true
          expect(page.has_link?((page_size + 1).to_s)).not_to be true
        end
        within '#products' do
          expect(page.has_css?('tr', count: 15)).to be true
        end

        page.select '30', from: 'page-size-selection'
        sleep 1
        within '#products' do
          expect(page.has_css?('tr', count: 30)).to be true
        end
        page_size = (products_count / 30.to_f).ceil
        within '#paginate_footer nav' do
          expect(page.has_link?(page_size.to_s)).to be true
          expect(page.has_link?((page_size + 1).to_s)).not_to be true
        end
      end
    end

    describe 'sort action' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Productos')).to be true
          click_link 'Productos'
        end
      end
      it 'sort by code' do
        sorted_by_code_asc = Product.select(:code).order(code: :asc).first
        sorted_by_code_desc = Product.select(:code).order(code: :desc).first
        # page.execute_script %{($("button.custom-sort-v1.btn-list-sort")[0]).click();}
        within '#table_results' do
          click_button 'Código'
        end

        within '#products' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_desc.code)
        end
        sleep 1
        within '#table_results' do
          click_button 'Código'
        end
        within '#products' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_asc.code)
        end
        sleep 1
        within '#table_results' do
          click_button 'Código'
        end
      end

      it 'sort by name' do
        sleep 3
        sorted_by_name_asc = Product.select(:name).order(name: :asc).first
        sorted_by_name_desc = Product.select(:name).order(name: :desc).first
        # page.execute_script %{($("button.custom-sort-v1.btn-list-sort")[0]).click();}
        within '#table_results' do
          click_button 'Nombre'
        end
        sleep 1
        within '#products' do
          puts sorted_by_name_asc.name
          sleep 5
          expect(page.first('tr').has_css?('td', text: sorted_by_name_asc.name)).to be true
        end

        within '#table_results' do
          click_button 'Nombre'
        end
        sleep 1
        within '#products' do
          expect(page.first('tr').has_css?('td', text: sorted_by_name_desc.name)).to be true
        end
        sleep 1
        within '#table_results' do
          click_button 'Nombre'
        end
        sleep 3
      end
      # it 'sort by name' do
      # end
    end
  end
end

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
          sleep 5
          # expect(page.has_css?("#loader-container")).to be true
        end

        within '#products' do
          expect(page.has_css?('tr', count: 1)).to be true
          sleep 2
        end
        within '#products-filter' do
          page.execute_script %{$("button.btn-clean-filters")[0].click()}
        end
        sleep 4
        within '#products-filter' do
          fill_in 'filter[name]', with: 'SOXUPRINA AMPOLLA'
          click_button 'Buscar'
          sleep 2
          # expect(page.has_css?("#loader-container")).to be true
        end
        within '#products' do
          expect(page.has_css?('tr', count: 1)).to be true
          sleep 2
        end
      end
    end
  end
end

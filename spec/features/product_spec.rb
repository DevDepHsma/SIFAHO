require 'rails_helper'

RSpec.feature 'Products', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Productos')
    @read_products = permission_module.permissions.find_by(name: 'read_products')
    @create_products = permission_module.permissions.find_by(name: 'create_products')
    @update_products = permission_module.permissions.find_by(name: 'update_products')
    @destroy_products = permission_module.permissions.find_by(name: 'destroy_products')
  end
  
  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }
    
    describe 'Add permission:' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_products)
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_products)
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_products)
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_products)
        visit '/'
      end
      it 'List' do
        expect(page).to have_css('#sidebar-wrapper', visible: false)
        within '#sidebar-wrapper' do
          expect(page).to have_link('Productos')
          click_link 'Productos'
        end
        within '#dropdown-menu-header' do
          expect(page).to have_link('Productos')
        end
      end

      it 'Show' do
        visit '/productos'
        within '#products' do
          expect(page).to have_css('.btn-detail')
        end
        product = Product.all.sample
        visit "/productos/#{product.id}"
        expect(page).to have_content("Viendo producto #{product.name}")
        expect(page).to have_content('Código')
        expect(page).to have_content(product.code.to_s)
        expect(page).to have_content('Nombre')
        expect(page).to have_content(product.name.to_s)
        expect(page).to have_content('Unidad')
        expect(page).to have_content(product.unity.name.to_s)
        expect(page).to have_content('Rubro')
        expect(page).to have_content(product.area.name.to_s)
        expect(page).to have_content('Descripción')
        expect(page).to have_content('Observación')
        expect(page).to have_link('Volver')
      end

      it 'Create: form and fields' do
        visit '/productos'
        within '#dropdown-menu-header' do
          expect(page).to have_link('Agregar')
          click_link 'Agregar'
        end
        within '#new_product' do
          expect(page).to have_field('product[code]', type: 'number')
          expect(page).to have_field('product[name]', type: 'text')
          expect(page).to have_select('product[unity_id]', visible: false)
          expect(page).to have_select('product[area_id]', visible: false)
          expect(page).to have_field('product[description]', type: 'textarea')
          expect(page).to have_field('product[observation]', type: 'textarea')
        end
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
      end

      it 'Edit: form and fields' do
        visit '/productos'
        within '#products' do
          expect(page).to have_css('.btn-edit')
        end
        product = Product.all.sample
        visit "/productos/#{product.id}/editar"
        within "#edit_product_#{product.id}" do
          expect(page).to have_field('product[code]', type: 'number', with: product.code)
          expect(page).to have_field('product[name]', type: 'text',  with: product.name)
          expect(page).to have_select('product[unity_id]', visible: false, with_selected: product.unity.name)
          expect(page).to have_select('product[area_id]', visible: false, with_selected: product.area.name)
          expect(page).to have_field('product[description]', type: 'textarea', with: product.description)
          expect(page).to have_field('product[observation]', type: 'textarea', with: product.observation)
        end
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
      end
    end

    #   within '#new_product' do
    #     fill_in 'product_code', with: '20818'
    #     fill_in 'product_name', with: 'Hidroclorotiazida 0.5% suspensión 100 ml (Magistral)'
    #     page.execute_script %{$('button:contains(Seleccionar unidad)').first().click()}
    #     page.execute_script %{$('button:contains(Seleccionar unidad)').first().siblings('.dropdown-menu').first().keydown('unidad')}
    #     page.execute_script %{$('a:contains(Unidad)').first().click()}

    #     page.execute_script %{$('button:contains(Seleccionar rubro)').first().click()}
    #     page.execute_script %{$('button:contains(Seleccionar rubro)').first().siblings('.dropdown-menu').first().keydown('Medicamentos')}
    #     page.execute_script %{$('a:contains(Medicamentos)').first().click()}
    #   end
    #   click_button 'Guardar'
    #   click_link 'Volver'
    #   within '#products' do
    #     expect(page).to have_selector('.btn-detail')
    #     expect(page).not_to have_selector('.btn-edit')
    #   end

    #   PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_products)
    #   visit current_path
    #   page.execute_script %{$('#filterrific_search_code').val('20818').keydown()}
    #   sleep 1
    #   within '#products' do
    #     expect(page).to have_selector('.delete-item')
    #     page.execute_script %{$('td:contains(Hidroclorotiazida 0.5% suspensión 100 ml (Magistral))').closest('tr').find('button.delete-item').first().click()}
    #   end
    #   sleep 1
    #   expect(page).to have_content('Eliminar producto')
    #   expect(page.has_button?('Volver')).to be true
    #   expect(page.has_link?('Confirmar')).to be true
    #   click_link 'Confirmar'
    #   sleep 1
    #   within '#products' do
    #     expect(page).to have_selector('.delete-item', count: 0)
    #     page.execute_script %{$('button.delete-item')[0].click()}
    #   end
    # end
    # end
  end
end

require 'rails_helper'

RSpec.feature "Products", type: :feature do
  before(:all) do
    @permission_module = create(:permission_module, name: 'Productos')
    @read_products = create(:permission, name: 'read_products', permission_module: @permission_module)
    @create_products = create(:permission, name: 'create_products', permission_module: @permission_module)
    @update_products = create(:permission, name: 'update_products', permission_module: @permission_module)
    @destroy_products = create(:permission, name: 'destroy_products', permission_module: @permission_module)
  end

  background do
    sign_in_as(@user)
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe "Add permission:" do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_products)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Productos')).to be true
          click_link 'Productos'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Productos')).to be true
        end

        within '#products' do
          expect(page).to have_selector('.btn-detail')
          page.execute_script %Q{$('a.btn-detail')[0].click()}
        end
        expect(page).to have_content('Viendo producto')
        expect(page.has_link?('Volver')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @create_products)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Agregar')).to be true
          click_link 'Agregar'
        end

        expect(page.has_css?('#product_code')).to be true
        expect(page.has_css?('#product_name')).to be true
        expect(page.has_css?('#product_unity_id', visible: false)).to be true
        expect(page.has_css?('#product_area_id', visible: false)).to be true
        expect(page.has_css?('#product_description')).to be true
        expect(page.has_css?('#product_observation')).to be true
        # expect(page.has_css?('#product_name_fake-', visible: false)).to be true
        within '#new_product' do
          fill_in 'product_code', with: '106'
          fill_in 'product_name', with: 'Alcohol Etílico 96º x 500 ml'
          page.execute_script %Q{$('button:contains(Seleccionar unidad)').first().click()}
          page.execute_script %Q{$('button:contains(Seleccionar unidad)').first().siblings('.dropdown-menu').first().keydown('unidad')}
          page.execute_script %Q{$('a:contains(Unidad)').first().click()}

          page.execute_script %Q{$('button:contains(Seleccionar rubro)').first().click()}
          page.execute_script %Q{$('button:contains(Seleccionar rubro)').first().siblings('.dropdown-menu').first().keydown('Medicamentos')}
          page.execute_script %Q{$('a:contains(Medicamentos)').first().click()}
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#products' do
          expect(page).to have_selector('.btn-detail')
          expect(page).not_to have_selector('.btn-edit')
        end
        PermissionUser.create(user: @user, sector: @user.sector, permission: @update_products)
        visit current_path
        within '#products' do
          expect(page).to have_selector('.btn-edit')
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando producto')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_products)
        visit current_path
        within '#products' do
          expect(page).to have_selector('.delete-item')
          page.execute_script %Q{$('td:contains(Alcohol Etílico 96º x 500 ml)').closest('tr').find('button.delete-item').first().click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar producto')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#products' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end

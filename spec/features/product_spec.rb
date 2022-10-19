require 'rails_helper'

RSpec.feature 'Products', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Productos')
    @read_products = permission_module.permissions.find_by(name: 'read_products')
    @create_products = permission_module.permissions.find_by(name: 'create_products')
    @update_products = permission_module.permissions.find_by(name: 'update_products')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_products)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_products)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_products)
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }

    describe 'Add permission:' do
      it 'List' do
        visit '/'
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
          expect(page).to have_field('product[name]', type: 'text', with: product.name)
          expect(page).to have_select('product[unity_id]', visible: false, with_selected: product.unity.name)
          expect(page).to have_select('product[area_id]', visible: false, with_selected: product.area.name)
          expect(page).to have_field('product[description]', type: 'textarea', with: product.description)
          expect(page).to have_field('product[observation]', type: 'textarea', with: product.observation)
        end
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
      end
    end

    describe 'Form' do
      describe 'Send' do
        it 'successfully' do
          visit '/productos/nuevo'

          within '#new_product' do
            fill_in 'product[code]', with: '20818'
            fill_in 'product[name]', with: 'Hidroclorotiazida 0.5% suspensión 100 ml (Magistral)'
            page.execute_script %{$('button:contains(Seleccionar unidad)').first().click()}
            page.execute_script %{$('button:contains(Seleccionar unidad)').first().siblings('.dropdown-menu').first().keydown('unidad')}
            page.execute_script %{$('a:contains(Unidad)').first().click()}

            page.execute_script %{$('button:contains(Seleccionar rubro)').first().click()}
            page.execute_script %{$('button:contains(Seleccionar rubro)').first().siblings('.dropdown-menu').first().keydown('Medicamentos')}
            page.execute_script %{$('a:contains(Medicamentos)').first().click()}
          end
          click_button 'Guardar'
          expect(page).to have_content('Viendo producto hidroclorotiazida 0.5% suspensión 100 ml (magistral)')
          expect(page).to have_content('Código: 20818')
          expect(page).to have_content('Unidad: Unidad')
          expect(page).to have_content('Rubro: Medicamentos')
        end

        describe 'Fail and validations' do
          before(:each) do
            visit '/productos/nuevo'
          end

          it 'displays required fields' do
            click_button 'Guardar'
            within '#new_product' do
              expect(page).to have_css('input[name="product[code]"].is-invalid')
              expect(page.find('input[name="product[code]"]+.invalid-feedback')).to have_content('Código no puede estar en blanco')

              expect(page).to have_css('input[name="product[name]"].is-invalid')
              expect(page.find('input[name="product[name]"]+.invalid-feedback')).to have_content('Nombre no puede estar en blanco')

              expect(page).to have_css('select[name="product[unity_id]"].is-invalid', visible: false)
              expect(page).to have_content('Unidad no puede estar en blanco')

              expect(page).to have_css('select[name="product[area_id]"].is-invalid', visible: false)
              expect(page).to have_content('Rubro no puede estar en blanco')
            end
          end

          it 'keep code attribute' do
            within '#new_product' do
              fill_in 'product[code]', with: 10_972
            end
            click_button 'Guardar'
            within '#new_product' do
              expect(page).to have_field('product[code]', with: 10_972)
            end
          end

          it 'keep name attribute' do
            within '#new_product' do
              fill_in 'product[name]', with: 'Cánula de alto flujo Drager Hi-Flow Star Tamaño L'
            end
            click_button 'Guardar'
            within '#new_product' do
              expect(page).to have_field('product[name]', with: 'Cánula de alto flujo Drager Hi-Flow Star Tamaño L')
            end
          end

          it 'keep unidad attribute' do
            within '#new_product' do
              page.execute_script %{$('button:contains(Seleccionar unidad)').first().click()}
              page.execute_script %{$('button:contains(Seleccionar unidad)').first().siblings('.dropdown-menu').first().keydown('unidad')}
              page.execute_script %{$('a:contains(Unidad)').first().click()}
            end
            click_button 'Guardar'
            within '#new_product' do
              expect(page).to have_select('product[unity_id]', visible: false, with_selected: 'Unidad')
            end
          end

          it 'keep medicamentos attribute' do
            within '#new_product' do
              page.execute_script %{$('button:contains(Seleccionar rubro)').first().click()}
              page.execute_script %{$('button:contains(Seleccionar rubro)').first().siblings('.dropdown-menu').first().keydown('Medicamentos')}
              page.execute_script %{$('a:contains(Medicamentos)').first().click()}
            end
            click_button 'Guardar'
            within '#new_product' do
              expect(page).to have_select('product[area_id]', visible: false, with_selected: 'Medicamentos')
            end
          end

          it 'keep description attribute' do
            within '#new_product' do
              fill_in 'product[description]',
                      with: 'A description for: Cánula de alto flujo Drager Hi-Flow Star Tamaño L'
            end
            click_button 'Guardar'
            within '#new_product' do
              expect(page).to have_field('product[description]',
                                         with: 'A description for: Cánula de alto flujo Drager Hi-Flow Star Tamaño L')
            end
          end

          it 'keep observation attribute' do
            within '#new_product' do
              fill_in 'product[observation]',
                      with: 'An observation for: Cánula de alto flujo Drager Hi-Flow Star Tamaño L'
            end
            click_button 'Guardar'
            within '#new_product' do
              expect(page).to have_field('product[observation]',
                                         with: 'An observation for: Cánula de alto flujo Drager Hi-Flow Star Tamaño L')
            end
          end
        end
      end
    end
  end
end

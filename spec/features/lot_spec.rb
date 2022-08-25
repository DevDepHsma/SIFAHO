require 'rails_helper'

RSpec.feature "Lots", type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Lotes')
    @read_lots = permission_module.permissions.find_by(name: 'read_lots')
    @create_lots = permission_module.permissions.find_by(name: 'create_lots')
    @update_lots = permission_module.permissions.find_by(name: 'update_lots')
    @destroy_lots = permission_module.permissions.find_by(name: 'destroy_lots')
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe "Add permission:" do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_lots)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Lotes Provincia')).to be true
          click_link 'Lotes Provincia'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Lotes provincia')).to be true
        end
        within '#lots' do
          expect(page).to have_selector('.btn-detail')
          page.execute_script %Q{$('a.btn-detail')[0].click()}
        end
        expect(page).to have_content('Viendo lote')
        expect(page.has_link?('Volver')).to be true
        click_link 'Volver'
        # Create
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_lots)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Agregar')).to be true
          click_link 'Agregar'
        end
        expect(page.has_css?('#lot_product_code_fake')).to be true
        expect(page.has_css?('#lot_product_name_fake')).to be true
        expect(page.has_css?('#lot_code')).to be true
        expect(page.has_css?('#lot_laboratory_id', visible: false)).to be true
        product = Product.first
        within '#new_lot' do
          page.execute_script %Q{$('#lot_product_code_fake').val("#{product.code}").keydown()}
        end
        sleep 1
        page.execute_script("$('.ui-menu-item:contains(#{product.code})').first().click()")
        within '#new_lot' do
          fill_in 'lot_code', with: 'BC456'
          page.execute_script %Q{$('#lot_laboratory_id').siblings('button').first().click()}
          expect(page.has_css?('ul.dropdown-menu')).to be true
          expect(page.has_css?('span', text: 'ABBOTT LABORATORIES ARGENTINA S.A.')).to be true
          page.execute_script %Q{$('a>span:contains(ABBOTT LABORATORIES ARGENTINA S.A.)').first().click()}
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#lots' do
          expect(page).to have_selector('.btn-detail')
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_lots)
        visit current_path
        within '#lots' do
          expect(page).to have_selector('.btn-edit')
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando lote')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_lots)
        visit current_path
        sleep 1
        page.execute_script %Q{$('#filterrific_search_lot_code').val('BC456').keydown()}
        sleep 1
        within '#lots' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %Q{$('td:contains("BC456")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar lote')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        expect(page).to have_content('Lote BC456 se ha eliminado correctamente.')
      end
    end
  end
end
require 'rails_helper'

RSpec.feature "Laboratories", type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Laboratorios')
    @read_laboratories = permission_module.permissions.find_by(name: 'read_laboratories')
    @create_laboratories = permission_module.permissions.find_by(name: 'create_laboratories')
    @update_laboratories = permission_module.permissions.find_by(name: 'update_laboratories')
    @destroy_laboratories = permission_module.permissions.find_by(name: 'destroy_laboratories')
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe "Add permission:" do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_laboratories)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Laboratorios')).to be true
          click_link 'Laboratorios'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Laboratorios')).to be true
        end

        within '#laboratories' do
          expect(page).to have_selector('.btn-detail')
          page.execute_script %Q{$('a.btn-detail')[0].click()}
        end
        expect(page).to have_content('Viendo laboratorio')
        expect(page.has_link?('Volver')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_laboratories)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Agregar')).to be true
          click_link 'Agregar'
        end

        expect(page.has_css?('#laboratory_name')).to be true
        expect(page.has_css?('#laboratory_cuit')).to be true
        expect(page.has_css?('#laboratory_gln')).to be true
        within '#new_laboratory' do
          fill_in 'laboratory_name', with: 'ABC Prueba'
          fill_in 'laboratory_cuit', with: '231112311'
          fill_in 'laboratory_gln', with: '12345678'
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#laboratories' do
          expect(page).to have_selector('.btn-detail', count: 2)
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_laboratories)
        visit current_path
        within '#laboratories' do
          expect(page).to have_selector('.btn-edit', count: 2)
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando laboratorio')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_laboratories)
        visit current_path
        within '#laboratories' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %Q{$('td:contains("ABC Prueba")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar laboratorio')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#laboratories' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end

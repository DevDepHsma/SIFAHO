require 'rails_helper'

RSpec.feature "Professionals", type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Profesionales')
    @read_professionals = permission_module.permissions.find_by(name: 'read_professionals')
    @create_professionals = permission_module.permissions.find_by(name: 'create_professionals')
    @update_professionals = permission_module.permissions.find_by(name: 'update_professionals')
    @destroy_professionals = permission_module.permissions.find_by(name: 'destroy_professionals')
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
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_professionals)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Médicos')).to be true
          click_link 'Médicos'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Médicos')).to be true
        end

        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_professionals)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Agregar')).to be true
          click_link 'Agregar'
        end

        expect(page.has_css?('#last-name')).to be true
        expect(page.has_css?('#first-name')).to be true
        within '#professional-form-async' do
          fill_in 'last-name', with: 'Gonzales'
          fill_in 'first-name', with: 'Gabriela'
        end
        sleep 2
        expect(page).to have_content('GONZALES GABRIELA INES | 26231509 | MP 1937')
        page.execute_script %Q{$('a.btn-success').first().click()}
        sleep 1
        expect(page).to have_content('Viendo médico')
        expect(page).to have_content('GONZALES')
        expect(page).to have_content('26231509')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_link?('Editar')).to be false
        click_link 'Volver'
        within '#professionals' do
          expect(page).to have_selector('.btn-detail', count: 1)
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_professionals)
        visit current_path
        within '#professionals' do
          expect(page).to have_selector('.btn-edit', count: 1)
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end

        expect(page).to have_content('Editando médico')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        click_link 'Volver'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_professionals)
        visit current_path
        within '#professionals' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %Q{$('td:contains("GABRIELA")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar Médico')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#professionals' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end

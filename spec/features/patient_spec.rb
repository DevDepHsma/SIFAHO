require 'rails_helper'

RSpec.feature "Patients", type: :feature do
  before(:all) do
    @patient_module = create(:permission_module, name: 'Pacientes')
    @read_patients = create(:permission, name: 'read_patients', permission_module: @patient_module)
    @create_patients = create(:permission, name: 'create_patients', permission_module: @patient_module)
    @update_patients = create(:permission, name: 'update_patients', permission_module: @patient_module)
    @destroy_patients = create(:permission, name: 'destroy_patients', permission_module: @patient_module)
    @patients = get_patients()
  end

  background do
    sign_in_as(@user)
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe 'Add permission:' do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_patients)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Pacientes')).to be true
          click_link 'Pacientes'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Pacientes')).to be true
        end

        # within '#patients' do
        #   expect(page).to have_selector('.btn-detail')
        #   page.execute_script %Q{$('a.btn-detail')[0].click()}
        # end
        # expect(page).to have_content('Viendo paciente')
        # expect(page.has_link?('Volver')).to be true
        # click_link 'Volver'
        PermissionUser.create(user: @user, sector: @user.sector, permission: @create_patients)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page.has_link?('Agregar')).to be true
          click_link 'Agregar'
        end
        @patient = @patients.sample
        expect(page.has_css?('#patient_dni')).to be true
        expect(page.has_css?('#patient_sex', visible: false)).to be true
        expect(page.has_css?('#patient_last_name')).to be true
        expect(page.has_css?('#patient_first_name')).to be true
        expect(page.has_css?('#patient_marital_status', visible: false)).to be true
        within '#new_patient' do
          fill_in 'patient_dni', with: @patient[0]
          click_button 'Otro'
          find('button', text: 'Otro').sibling('div', class: 'dropdown-menu').find('a', text: @patient[1]).click
          fill_in 'patient_last_name', with: @patient[2]
          fill_in 'patient_first_name', with: @patient[3]
          click_button 'soltero'
          find('button', text: 'soltero').sibling('div', class: 'dropdown-menu').find('a', text: @patient[4]).click
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#patients' do
          expect(page).to have_selector('.btn-detail', count: 1)
        end
        PermissionUser.create(user: @user, sector: @user.sector, permission: @update_patients)
        visit current_path
        within '#patients' do
          expect(page).to have_selector('.btn-edit', count: 1)
          page.execute_script %Q{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando paciente')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        fill_in 'patient_first_name', with: 'Gadiel Rafael Pedro'
        click_button 'Guardar'
        expect(page).to have_content('Gadiel Rafael Pedro')
        click_link 'Volver'

        PermissionUser.create(user: @user, sector: @user.sector, permission: @destroy_patients)
        visit current_path
        within '#patients' do
          expect(page).to have_selector('.delete-item', count: 1)
          page.execute_script %Q{$('td:contains("Gadiel Rafael Pedro")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar paciente')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        within '#patients' do
          expect(page).to have_selector('.delete-item', count: 0)
          page.execute_script %Q{$('button.delete-item')[0].click()}
        end
      end
    end
  end
end

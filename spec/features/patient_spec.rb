require 'rails_helper'

RSpec.feature 'Patients', type: :feature do
  before(:all) do
    patient_module = PermissionModule.includes(:permissions).find_by(name: 'Pacientes')
    @read_patients = patient_module.permissions.find_by(name: 'read_patients')
    @create_patients = patient_module.permissions.find_by(name: 'create_patients')
    @update_patients = patient_module.permissions.find_by(name: 'update_patients')
    @destroy_patients = patient_module.permissions.find_by(name: 'destroy_patients')
    @patients = Patient.all
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe 'Add permission:' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_patients)
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

        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_patients)
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
          fill_in 'patient_dni', with: 37_458_995
          click_button 'Otro'
          find('button', text: 'Otro').sibling('div', class: 'dropdown-menu').find('a', text: 'Femenino').click
          fill_in 'patient_last_name', with: 'BUGANEM'
          fill_in 'patient_first_name', with: 'MICAELA ESTER'
          click_button 'soltero'
          find('button', text: 'soltero').sibling('div', class: 'dropdown-menu').find('a', text: 'soltero').click
        end
        click_button 'Guardar'
        click_link 'Volver'
        within '#patients' do
          expect(page).to have_selector('.btn-detail')
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_patients)
        visit current_path
        within '#patients' do
          expect(page).to have_selector('.btn-edit')
          page.execute_script %{$('a.btn-edit')[0].click()}
        end
        expect(page).to have_content('Editando paciente')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        fill_in 'patient_first_name', with: 'Gadiel Rafael Pedro'
        click_button 'Guardar'
        sleep 1
        expect(page).to have_content('gadiel rafael pedro')
        click_link 'Volver'

        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_patients)
        visit current_path
        within '#patients' do
          expect(page).to have_selector('.delete-item')
          page.execute_script %{$('td:contains("gadiel rafael pedro")').closest('tr').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar paciente')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
      end
    end
  end
end

#  Test information

#  Testing modules:
#  Access permissions: List / Show /Create / Edit
#  Present fields on create
#  Present fields and values on edit
#  Save product
#  Validations on empty form
#  Check present field values on Save fails
#

require 'rails_helper'

RSpec.feature 'Patients', type: :feature do
  before(:all) do
    patient_module = PermissionModule.includes(:permissions).find_by(name: 'Pacientes')
    @read_patients = patient_module.permissions.find_by(name: 'read_patients')
    @create_patients = patient_module.permissions.find_by(name: 'create_patients')
    @update_patients = patient_module.permissions.find_by(name: 'update_patients')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_patients)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_patients)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_patients)
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe 'Add permission:' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_patients)
        visit '/'
        expect(page).to have_css('#sidebar-wrapper', visible: false)
        within '#sidebar-wrapper' do
          expect(page).to have_link('Pacientes')
          click_link 'Pacientes'
        end
        within '#dropdown-menu-header' do
          expect(page).to have_link('Pacientes')
        end
      end

      it 'Show' do
        visit '/pacientes'
        within '#patients' do
          expect(page).to have_css('.btn-detail')
        end
        patient = Patient.all.sample
        visit "/pacientes/#{patient.id}"
        expect(page).to have_content('Viendo paciente')
        expect(page).to have_content('Apellido')
        expect(page).to have_content(patient.first_name.to_s)
        expect(page).to have_content('Nombre')
        expect(page).to have_content(patient.last_name.to_s)
        expect(page).to have_content('DNI')
        expect(page).to have_content(patient.dni)
        expect(page).to have_content('Sexo')
        expect(page).to have_content(patient.sex)
        expect(page).to have_content('Fecha nacimiento')
        expect(page).to have_content(patient.birthdate.strftime('%d/%m/%Y'))
        expect(page).to have_content('Estado civil')
        expect(page).to have_content(patient.marital_status)
        expect(page).to have_content('Email')
        expect(page).to have_content('Teléfonos')
        expect(page).to have_link('Volver')
      end

      it 'Create: form and fields' do
        visit '/pacientes'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                              permission: @create_patients)
        visit current_path
        within '#dropdown-menu-header' do
          expect(page).to have_link('Agregar')
          click_link 'Agregar'
        end
        within '#new_patient' do
          expect(page).to have_field('patient[dni]', type: 'text')
          expect(page).to have_select('patient[sex]', visible: false)
          expect(page).to have_field('patient[birthdate]', type: 'text')
          expect(page).to have_field('patient[last_name]', type: 'text')
          expect(page).to have_field('patient[first_name]', type: 'text')
          expect(page).to have_select('patient[marital_status]', visible: false)
          expect(page).to have_content('Teléfonos')
          expect(page).to have_field('patient[email]', type: 'email')
          expect(page).to have_select('patient[patient_phones_attributes][0][phone_type]', visible: false)
          expect(page).to have_field('patient[patient_phones_attributes][0][number]', type: 'text')
          expect(page).to have_field('patient[patient_phones_attributes][0][_destroy]', type: 'hidden',
                                                                                        visible: false)
        end
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
        click_button 'Guardar'
        click_link 'Volver'
        within '#patients' do
          expect(page).to have_selector('.btn-detail')
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                              permission: @update_patients)
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
        expect(page).to have_content('gadiel rafael pedro')
        click_link 'Volver'
      end

      it 'Edit: form and fields' do
        visit '/pacientes'
        within '#patients' do
          expect(page).to have_css('.btn-edit')
        end
        patient = Patient.all.sample
        visit "/pacientes/#{patient.id}/editar"
        within "#edit_patient_#{patient.id}" do
          expect(page).to have_field('patient[dni]', type: 'text')
          expect(page).to have_select('patient[sex]', visible: false)
          expect(page).to have_field('patient[birthdate]', type: 'text')
          expect(page).to have_field('patient[last_name]', type: 'text')
          expect(page).to have_field('patient[first_name]', type: 'text')
          expect(page).to have_select('patient[marital_status]', visible: false)
          expect(page).to have_content('Teléfonos')
          expect(page).to have_field('patient[email]', type: 'email')
        end
        expect(page).to have_link('Volver')
        expect(page).to have_button('Guardar')
      end
    end

    describe 'Form' do
      describe 'Send' do
        it 'successfully' do
          visit '/pacientes/nuevo'

          within '#new_patient' do
            fill_in 'patient[dni]', with: '33896578'
            page.execute_script %{$('button:contains(Otro)').first().click()}
            page.execute_script %{$('button:contains(Otro)').first().siblings('.dropdown-menu').first().keydown('F')}
            page.execute_script %{$('a:contains(Femenino)').first().click()}
            fill_in 'patient[birthdate]', with: '20/10/1994'
            page.execute_script %{$('.active.day').click()}
            fill_in 'patient[last_name]', with: 'Navarro'
            fill_in 'patient[first_name]', with: 'Magali'
            page.execute_script %{$('button:contains(soltero)').first().click()}
            page.execute_script %{$('button:contains(soltero)').first().siblings('.dropdown-menu').first().keydown('C')}
            page.execute_script %{$('a:contains(casado)').first().click()}
            fill_in 'patient[email]', with: 'magalita2022@gmail.com'
            page.execute_script %{$('button:contains(Móvil)').first().click()}
            page.execute_script %{$('button:contains(Móvil)').first().siblings('.dropdown-menu').first().keydown('c')}
            page.execute_script %{$('a:contains(celular)').first().click()}
            fill_in 'patient[patient_phones_attributes][0][number]', with: '2990000000'
          end
          click_button 'Guardar'
          expect(page).to have_content('Viendo paciente')
          expect(page).to have_content('Apellido')
          expect(page).to have_content('navarro')
          expect(page).to have_content('Nombre')
          expect(page).to have_content('magali')
          expect(page).to have_content('DNI')
          expect(page).to have_content('33896578')
        end

        describe 'Fail and validations' do
          before(:each) do
            visit '/pacientes/nuevo'
          end

          it 'displays required fields' do
            click_button 'Guardar'
            within '#new_patient' do
              expect(page).to have_css('input[name="patient[dni]"].is-invalid')
              expect(page.find('input[name="patient[dni]"]+.invalid-feedback')).to have_content('Dni no puede estar en blanco y Dni no es un número')
              expect(page).to have_css('input[name="patient[birthdate]"].is-invalid')
              expect(page.find('input[name="patient[birthdate]"]+.invalid-feedback')).to have_content('Fecha de nacimiento no puede estar en blanco')
              expect(page).to have_css('input[name="patient[last_name]"].is-invalid')
              expect(page.find('input[name="patient[last_name]"]+.invalid-feedback')).to have_content('Apellido no puede estar en blanco')
              expect(page).to have_css('input[name="patient[first_name]"].is-invalid')
              expect(page.find('input[name="patient[first_name]"]+.invalid-feedback')).to have_content('Nombre no puede estar en blanco')
            end
          end

          it 'keep dni attribute' do
            within '#new_patient' do
              fill_in 'patient[dni]', with: 33_796_578
            end
            click_button 'Guardar'
            within '#new_patient' do
              expect(page).to have_field('patient[dni]', with: 33_796_578)
            end
          end

          it 'keep last_name attribute' do
            within '#new_patient' do
              fill_in 'patient[last_name]', with: 'Lutero'
            end
            click_button 'Guardar'
            within '#new_patient' do
              expect(page).to have_field('patient[last_name]', with: 'Lutero')
            end
          end

          it 'keep  first_name attribute' do
            within '#new_patient' do
              fill_in 'patient[first_name]', with: 'Martin'
            end
            click_button 'Guardar'
            within '#new_patient' do
              expect(page).to have_field('patient[first_name]', with: 'Martin')
            end
          end
        end
      end
    end
  end
end

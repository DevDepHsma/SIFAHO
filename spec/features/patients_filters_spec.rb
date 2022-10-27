require 'rails_helper'

RSpec.feature 'PatientsFilters', type: :feature do
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
    before(:each) do
      PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_patients)
      visit '/'
    end
    after(:each) do
      sleep 1
      sign_out_as(@farm_applicant)
    end
    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
      within '#sidebar-wrapper' do
        expect(page.has_link?('Pacientes')).to be true
        click_link 'Pacientes'
      end
    end

    describe 'filter form' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Pacientes')).to be true
          click_link 'Pacientes'
        end
      end
      it 'displays dni' do
        within '#patients-filter' do
          expect(page.has_css?('input[name="filter[dni]"]')).to be true
        end
      end
      it 'displays search full name' do
        within '#patients-filter' do
          expect(page.has_css?('input[name="filter[full_name]"]')).to be true
        end
      end
      it 'displays button "Buscar"' do
        within '#patients-filter' do
          expect(page.has_button?('Buscar')).to be true
        end
      end
      it 'displays button limpiar' do
        within '#patients-filter' do
          expect(page.has_css?('.btn-clean-filters')).to be true
        end
      end
    end

    describe 'form actions' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Pacientes')).to be true
          click_link 'Pacientes'
        end
      end
      it 'displays loader on click "Buscar"' do
        within '#patients-filter' do
          click_button 'Buscar'
        end
      end
      it 'displays dni results' do
        patients = Patient.all.sample(5)
        patients.each do |patient|
          within '#patients-filter' do
            fill_in 'filter[dni]', with: patient.dni
            click_button 'Buscar'
            sleep 1
          end
          within '#patients' do
            expect(page.first('tr').first('td')).to have_content(patient.dni)
          end

          within '#patients-filter' do
            page.execute_script %{$("button.btn-clean-filters")[0].click()}
          end
          sleep 1
        end
      end

      it 'displays fullname results' do
        patients = Patient.all.sample(5)
        patients.each do |patient|
          within '#patients-filter' do
            fill_in 'filter[full_name]', with: patient.first_name.to_s
            click_button 'Buscar'
            sleep 1
          end
          within '#patients' do
            expect(page.first('#patients tr mark')).to have_content(patient.first_name.to_s)
          end

          within '#patients-filter' do
            page.execute_script %{$("button.btn-clean-filters")[0].click()}
          end
          sleep 1
        end
      end
    end
  end
end

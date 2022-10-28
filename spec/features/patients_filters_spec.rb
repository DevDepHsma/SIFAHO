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

    describe 'paginator actions' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Pacientes')).to be true
          click_link 'Pacientes'
        end
      end

      it 'change page' do
        sleep 1
        within '#paginate_footer nav' do
          # page.execute_script %{$(".page-item a")[0].click()}
          expect(page.has_css?('li.active', text: '1')).to be true
          click_link '2'
          sleep 1
          expect(page.has_css?('li.active', text: '2')).to be true
          # page.execute_script %{$(".page-item")[2].getAttribute('class').indexOf('active')!=-1}
        end
      end
      it 'checks pages count' do
        patients_count = Patient.all.count
        page_size = (patients_count / 15.to_f).ceil
        within '#paginate_footer nav' do
          expect(page.has_link?(page_size.to_s)).to be true
          expect(page.has_link?((page_size + 1).to_s)).not_to be true
        end
      end

      it 'checks results count by page' do
        patients_count = Patient.all.count
        page_size = (patients_count / 15.to_f).ceil
        within '#paginate_footer nav' do
          expect(page.has_link?(page_size.to_s)).to be true
          expect(page.has_link?((page_size + 1).to_s)).not_to be true
        end
        within '#patients' do
          expect(page.has_css?('tr', count: 15)).to be true
        end

        page.select '30', from: 'page-size-selection'
        sleep 1
        within '#patients' do
          expect(page.has_css?('tr', count: 30)).to be true
        end
        page_size = (patients_count / 30.to_f).ceil
        within '#paginate_footer nav' do
          expect(page.has_link?(page_size.to_s)).to be true
          expect(page.has_link?((page_size + 1).to_s)).not_to be true
        end
      end
    end

    describe 'Sort' do
      before(:each) do
        within '#sidebar-wrapper' do
          expect(page.has_link?('Pacientes')).to be true
          click_link 'Pacientes'
        end
      end
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Dni')
          expect(page).to have_button('Nombre y apellido')
        end
      end

      it 'by code' do
        sorted_by_dni_asc = Patient.select(:dni).order(dni: :asc).first
        sorted_by_dni_desc = Patient.select(:dni).order(dni: :desc).first

        within '#table_results' do
          click_button 'Dni'
          sleep 1
        end

        within '#patients' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_dni_asc.dni)
        end

        within '#table_results' do
          click_button 'Dni'
          sleep 1
        end

        within '#patients' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_dni_desc.dni)
        end
      end

      it 'by name' do
        sorted_by_first_name_asc = Patient.select(:first_name).order(first_name: :asc).first
        sorted_by_first_name_desc = Patient.select(:first_name).order(first_name: :desc).first

        within '#table_results' do
          click_button 'Nombre y apellido'
          sleep 1
        end

        within '#patients' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_first_name_asc.first_name)
        end

        within '#table_results' do
          click_button 'Nombre y apellido'
          sleep 1
        end

        within '#patients' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_first_name_desc.first_name)
        end
      end
    end
  end
end

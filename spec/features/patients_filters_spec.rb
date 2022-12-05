require 'rails_helper'

RSpec.feature 'PatientsFilters', type: :feature do
  before(:all) do
    patient_module = PermissionModule.includes(:permissions).find_by(name: 'Pacientes')
    @read_patients = patient_module.permissions.find_by(name: 'read_patients')
    @create_patients = patient_module.permissions.find_by(name: 'create_patients')
    @update_patients = patient_module.permissions.find_by(name: 'update_patients')
    @destroy_patients = patient_module.permissions.find_by(name: 'destroy_patients')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_patients)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @destroy_patients)
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }
    before(:each) do
      visit '/'
    end
    it 'Nav Menu link' do
      expect(page).to have_selector('#sidebar-wrapper', visible: false)
      within '#sidebar-wrapper' do
        expect(page).to have_selector('.list-group-item.list-group-item-action.list-custom', text: 'Pacientes')
        click_link 'Pacientes'
      end
      expect(page).to have_selector('tbody#patients')
    end

    describe 'filter form' do
      before(:each) do
        visit '/pacientes'
      end
      it 'has_fields' do
        within '#patients-filter' do
          expect(page).to have_field('filter[dni]', type: 'text')
          expect(page).to have_field('filter[full_name]', type: 'text')
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button', class: 'btn-clean-filters')
        end
      end

      it 'by dni' do
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
            page.first('button.btn-clean-filters').click
          end
          sleep 1
        end
      end

      it 'by fullname' do
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
            page.first('button.btn-clean-filters').click
          end
          sleep 1
        end
      end
    end

    describe 'paginator actions' do
      before(:each) do
        @last_page = (Patient.all.count / 15.to_f).ceil
        visit '/pacientes'
      end

      it 'has pagination' do
        within '#paginate_footer nav' do
          expect(page).to have_selector('a.page-link', text: @last_page.to_s)
        end
      end

      it 'has pagination size selector' do
        within '#paginate_footer' do
          expect(page).to have_select('page-size-selection', with_options: %w[15 30 50 100])
        end
      end

      it 'change page number' do
        within '#paginate_footer nav' do
          expect(page).to have_selector('li.active', text: '1')
          click_link @last_page.to_s
          sleep 1
          expect(page).to have_selector('li.active', text: @last_page.to_s)
        end
      end

      it 'has 15 items per page by default' do
        within '#patients' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#patients' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end

    describe 'Sort' do
      before(:each) do
        visit '/pacientes'
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
    describe 'Destroy permission' do
      before(:each) do
        click_link 'Pacientes'
        @patient_to_del = @patients_without_prescriptions.sample
        within '#patients-filter' do
          fill_in 'filter[dni]', with: @patient_to_del.dni
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button destroy' do
        within '#patients' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#patients' do
          page.first('button.delete-item').click
          sleep 2
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar paciente')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'destroy items' do
        within '#patients' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          click_link 'Confirmar'
          sleep 1
        end
        expect(page).to have_text("El paciente #{@patient_to_del.last_name} #{@patient_to_del.first_name} #{@patient_to_del.dni} se ha eliminado correctamente.")
      end
    end
  end
end

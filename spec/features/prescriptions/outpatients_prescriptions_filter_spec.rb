require 'rails_helper'

RSpec.feature 'OutpatientsPrescriptionsFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Ambulatorias')
    @read_outpatient_permission = permission_module.permissions.find_by(name: 'read_outpatient_recipes')
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_outpatient_permission)
    @outpatients = OutpatientPrescription.all.sample(5)
  end

  background do
    sign_in_as(@farm_provider)
  end

  describe 'Outpatient Recipes ::', js: true do
    subject { page }

    it 'show "Recetas" link' do
      visit '/recetas/ambulatorias'
    end

    # describe 'filters columns table' do
    #   before(:each) do
    #     visit '/recetas/ambulatorias'
    #   end
    #   after(:each) do
    #     sleep 1
    #     sign_out_as(@farm_provider)
    #   end
    #   it 'verify form' do
    #     expect(page.has_css?('#outpatient-prescriptions-filter')).to be true
    #     expect(page.has_css?('#filter_code')).to be true
    #     expect(page.has_css?('#filter_professional_full_name')).to be true
    #     expect(page.has_css?('#filter_patient_full_name')).to be true
    #     expect(page.has_css?('#filter_date_prescribed_since')).to be true
    #     expect(page.has_css?('#filter_date_prescribed_to')).to be true
    #     expect(page.has_css?('select[name="filter[status]"')).to be true
    #     expect(page.has_button?('Buscar')).to be true
    #     expect(page.has_css?('.btn-clean-filters')).to be true
    #   end
    #   it 'sarch by code' do
    #     @outpatients.each do |outpatient|
    #       within '.filter-form-row' do
    #         fill_in 'filter[code]', with: outpatient.remit_code
    #         click_button 'Buscar'
    #       end

    #       sleep 1
    #       within '#outpatient_prescriptions' do
    #         expect(page.first('tr').first('td')).to have_content(outpatient.remit_code)
    #       end
    #       sleep 1
    #       within '.filter-form-row' do
    #         page.execute_script %{$("button.btn-clean-filters")[0].click()}
    #       end
    #     end
    #   end
    #   it 'search by profesional' do
    #     @outpatients.each do |outpatient|
    #       within '.filter-form-row' do
    #         fill_in 'filter[professional_full_name]', with: outpatient.professional.fullname
    #         click_button 'Buscar'
    #       end
    #       sleep 1
    #       within '#outpatient_prescriptions' do
    #         expect(page.first('tr').has_css?('td', text: outpatient.professional.fullname)).to be true
    #       end
    #       sleep 1
    #       within '.filter-form-row' do
    #         page.execute_script %{$("button.btn-clean-filters")[0].click()}
    #       end
    #     end
    #   end

    #   it 'search by patient' do
    #     sleep 1

    #     @outpatients.each do |outpatient|
    #       within '.filter-form-row' do
    #         fill_in 'filter[patient_full_name]', with: outpatient.patient.dni
    #         click_button 'Buscar'
    #       end

    #       sleep 1
    #       within '#outpatient_prescriptions' do
    #         expect(page.first('tr').has_css?('td', text: outpatient.patient.dni)).to be true
    #       end
    #       sleep 1
    #       within '.filter-form-row' do
    #         page.execute_script %{$("button.btn-clean-filters")[0].click()}
    #       end

    #       within '.filter-form-row' do
    #         fill_in 'filter[patient_full_name]', with: outpatient.patient.last_name
    #         click_button 'Buscar'
    #       end

    #       sleep 1
    #       within '#outpatient_prescriptions' do
    #         expect(page.first('tr').has_css?('td', text: outpatient.patient.last_name)).to be true
    #       end
    #       sleep 1
    #       within '.filter-form-row' do
    #         page.execute_script %{$("button.btn-clean-filters")[0].click()}
    #       end
    #       sleep 1
    #       within '.filter-form-row' do
    #         fill_in 'filter[patient_full_name]', with: outpatient.patient.first_name
    #         click_button 'Buscar'
    #       end
    #       sleep 1
    #       within '#outpatient_prescriptions' do
    #         expect(page.first('tr').has_css?('td', text: outpatient.patient.first_name)).to be true
    #       end
    #       sleep 1
    #       within '.filter-form-row' do
    #         page.execute_script %{$("button.btn-clean-filters")[0].click()}
    #       end
    #     end
    #   end

    #   it 'search by date' do
    #     date_to = DateTime.current.to_date.strftime('%d/%m/%Y')
    #     date_since = date_to.to_date - 365

    #     within '.filter-form-row' do
    #       fill_in 'filter[date_prescribed_since]', with: date_since
    #       fill_in 'filter[date_prescribed_to]', with: date_to
    #       click_button 'Buscar'
    #       sleep 1
    #     end
    #     within '#outpatient_prescriptions' do
    #       expect(page.first('tr').has_css?('td')).to be true
    #     end
    #     within '.filter-form-row' do
    #       page.execute_script %{$("button.btn-clean-filters")[0].click()}
    #     end
    #   end

    #   it 'filter by state' do
    #     page.select 'dispensada', from: 'filter[status]'
    #     click_button 'Buscar'
    #     sleep 1
    #     within '#outpatient_prescriptions' do
    #       expect(page.first('tr').has_css?('td span', text: 'Dispensada')).to be true
    #     end
    #     page.select 'vencida', from: 'filter[status]'
    #     click_button 'Buscar'
    #     sleep 1
    #     within '#outpatient_prescriptions' do
    #       expect(page.first('tr').has_css?('td span',text: 'Vencida')).to be true
    #     end
    #     page.select 'pendiente', from: 'filter[status]'
    #     click_button 'Buscar'
    #     sleep 1
    #     within '#outpatient_prescriptions' do
    #       expect(page.first('tr').has_css?('td span',text: 'Pendiente')).to be true
    #     end
    #   end
    # end
    # describe 'pagination actions' do
    #   before(:each) do
    #     visit '/recetas/ambulatorias'
    #   end
    #   after(:each) do
    #     sleep 1
    #     sign_out_as(@farm_provider)
    #   end
    #   it 'change page' do
    #     sleep 1
    #     within '#paginate_footer nav' do
    #       expect(page.has_css?('li.active', text: '1')).to be true
    #       click_link '2'
    #       sleep 1
    #       expect(page.has_css?('li.active', text: '2')).to be true
    #     end
    #   end
    #   it 'checks pages count' do
    #     prescriptions_count = OutpatientPrescription.all.count
    #     page_size = (prescriptions_count / 15.to_f).ceil
    #     within '#paginate_footer nav' do
    #       expect(page.has_link?(page_size.to_s)).to be true
    #       expect(page.has_link?((page_size + 1).to_s)).not_to be true
    #     end
    #   end

    #   it 'checks results count by page' do
    #     prescriptions_count = OutpatientPrescription.all.count
    #     page_size = (prescriptions_count / 15.to_f).ceil
    #     within '#paginate_footer nav' do
    #       expect(page.has_link?(page_size.to_s)).to be true
    #       expect(page.has_link?((page_size + 1).to_s)).not_to be true
    #     end
    #     within '#outpatient_prescriptions' do
    #       expect(page.has_css?('tbody tr', count: 15)).to be true
    #     end

    #     page.select '30', from: 'page-size-selection'
    #     sleep 1
    #     within '#outpatient_prescriptions' do
    #       expect(page.has_css?('tbody tr', count: 30)).to be true
    #     end
    #     page_size = (prescriptions_count / 30.to_f).ceil
    #     within '#paginate_footer nav' do
    #       expect(page.has_link?(page_size.to_s)).to be true
    #       expect(page.has_link?((page_size + 1).to_s)).not_to be true
    #     end
    #   end
    # end
    describe 'sort action' do
      before(:each) do
        visit '/recetas/ambulatorias'
      end
      after(:each) do
        sleep 1
        sign_out_as(@farm_provider)
      end
      it 'sort by fullname professional' do
        sorted_by_professional_asc = OutpatientPrescription.select('professionals.fullname AS pr_fullname').joins(:professional).order('pr_fullname asc').first
        sorted_by_professional_desc = OutpatientPrescription.select('professionals.fullname AS pr_fullname').joins(:professional).order('pr_fullname desc').first
        within '#table_results' do
          click_button 'Médico'
        end
        sleep 1
        within '#outpatient_prescriptions' do
          expect(page.first('tr').has_css?('td', text: sorted_by_professional_asc.pr_fullname)).to be true
        end
        sleep 1
        within '#table_results' do
          click_button 'Médico'
        end
        sleep 1
        within '#outpatient_prescriptions' do
          expect(page.first('tr').has_css?('td', text: sorted_by_professional_desc.pr_fullname)).to be true
        end
        sleep 1
        within '#table_results' do
          click_button 'Médico'
        end
      end
###############Falta terminar esta seccion de ordenamiento por fullname de paciente##########################
      # it 'sort by patient fullname ' do
      #   sorted_by_patient_asc = OutpatientPrescription.select('CONCAT(patients.last_name,\'\',patients.first_name,\' \',patients.dni) AS pt_fullname').joins(:patient).order('pt_fullname asc').first
      #   sorted_by_patient_desc = OutpatientPrescription.select('CONCAT(patients.last_name,\'\',patients.first_name,\' \',patients.dni) AS pt_fullname').joins(:patient).order('pt_fullname desc').first
      #   # page.execute_script %{($("button.custom-sort-v1.btn-list-sort")[0]).click();}
      #   within '#table_results' do
      #     click_button 'Paciente'
      #   end
      #   sleep 1
      #   within '#outpatient_prescriptions' do
      #     sleep 5
      #     expect(page.first('tr').has_css?('td', text: sorted_by_patient_asc.pt_fullname)).to be true
      #   end

      #   within '#table_results' do
      #     click_button 'Paciente'
      #   end
      #   sleep 1
      #   within '#outpatient_prescriptions' do
      #     expect(page.first('tr').has_css?('td', text: sorted_by_patient_desc.pt_fullname)).to be true
      #   end
      #   sleep 1
      #   within '#table_results' do
      #     click_button 'Paciente'
      #   end
      #   sleep 3
      # end
    end
  end
end

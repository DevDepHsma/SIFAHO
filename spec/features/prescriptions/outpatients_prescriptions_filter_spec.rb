require 'rails_helper'

RSpec.feature 'OutpatientsPrescriptionsFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Ambulatorias')
    @read_outpatient_permission = permission_module.permissions.find_by(name: 'read_outpatient_recipes')
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_outpatient_permission)
  end

  background do
    sign_in_as(@farm_provider)
  end

  describe 'Outpatient Recipes ::', js: true do
    subject { page }

    it 'show "Recetas" link' do
      visit '/recetas/ambulatorias'
    end

    describe 'filters columns table' do
      before(:each) do
        visit '/recetas/ambulatorias'
      end
      after(:each) do
        sleep 1
        sign_out_as(@farm_provider)
      end
      it 'verify form' do
        expect(page.has_css?('#outpatient-prescriptions-filter')).to be true
      end
      it 'sarch by code' do
        outpatients = OutpatientPrescription.all.sample(5)
        outpatients.each do |outpatient|
          within '.filter-form-row' do
            fill_in 'filter[code]', with: outpatient.remit_code
            click_button 'Buscar'
          end

          sleep 1
          within '#outpatient_prescriptions' do
            expect(page.first('tr').first('td')).to have_content(outpatient.remit_code)
          end
          sleep 1
          within '.filter-form-row' do
            page.execute_script %{$("button.btn-clean-filters")[0].click()}
          end
        end
      end
      it 'search by profesional' do
        outpatients = OutpatientPrescription.all.sample(5)
        outpatients.each do |outpatient|
          within '.filter-form-row' do
            fill_in 'filter[professional_full_name]', with: outpatient.professional.fullname
            click_button 'Buscar'
          end
          sleep 1
          within '#outpatient_prescriptions' do
            expect(page.first('tr').has_css?('td', text: outpatient.professional.fullname)).to be true
          end
          sleep 1
          within '.filter-form-row' do
            page.execute_script %{$("button.btn-clean-filters")[0].click()}
          end
        end
      end

      it 'search by patient' do
        sleep 1
        outpatients = OutpatientPrescription.includes(:patient).all.sample(5)
        outpatients.each do |outpatient|
          within '.filter-form-row' do
            fill_in 'filter[patient_full_name]', with: outpatient.patient.dni
            click_button 'Buscar'
          end
          patient_full_name = "#{outpatient.patient.last_name} #{outpatient.patient.first_name} #{outpatient.patient.dni}"
          sleep 1
          within '#outpatient_prescriptions' do
            expect(page.first('tr').has_css?('td', text: outpatient.patient.dni)).to be true
          end
          sleep 1
          within '.filter-form-row' do
            page.execute_script %{$("button.btn-clean-filters")[0].click()}
          end

          ######################### Falta finalizar este spec (verificar busqueda por nombre y/o apellido del paciente)######################################
          # within '.filter-form-row' do
          #   fill_in 'filter[patient_full_name]', with: outpatient.patient.last_name
          #   click_button 'Buscar'
          # end

          # sleep 1
          # within '#outpatient_prescriptions' do
          #   expect(page.first('tr').has_css?('td', text: outpatient.patient.last_name)).to be true

          # end
          # sleep 1
          # within '.filter-form-row' do
          #   page.execute_script %{$("button.btn-clean-filters")[0].click()}
          # end

          # within '.filter-form-row' do
          #   fill_in 'filter[patient_full_name]', with: outpatient.patient.first_name
          #   click_button 'Buscar'
          # end
          # sleep 1
          # within '#outpatient_prescriptions' do
          #   expect(page.first('tr').has_css?('td', text: outpatient.patient.first_name)).to be true
          # end
          # sleep 1
          # within '.filter-form-row' do
          #   page.execute_script %{$("button.btn-clean-filters")[0].click()}
          # end
        end
      end
      ######################### Falta finalizar estos  spec######################################
      # it 'search by date' do

      # date_since = DateTime.new(2021, 0o7, 11, 20, 10, 0, '-03').to_date.strftime('%d/%m/%Y')
      # date_to = DateTime.current.to_date.strftime('%d/%m/%Y')
      # describe '' do
      #   within '.filter-form-row' do
      #     fill_in 'filter[date_prescribed_since]', with: date_since
      #     fill_in 'filter[date_prescribed_to]', with: date_to
      #     click_button 'Buscar'
      #   end
      # end
      # end

      # it 'filter by state' do

      # end
    end
  end
end
